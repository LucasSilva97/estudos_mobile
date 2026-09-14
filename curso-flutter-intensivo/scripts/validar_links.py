"""Verifica destinos Markdown locais e âncoras, sem acesso à rede ou alterações."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]


def texto_sem_codigo(texto: str) -> str:
    return re.sub(r"^(`{3,}|~{3,}).*?^\1\s*$", "", texto, flags=re.M | re.S)


def ancoras(texto: str) -> set[str]:
    texto = texto_sem_codigo(texto)
    resultado = set(re.findall(r'<a\s+(?:id|name)=[\"\']([^\"\']+)', texto))
    repeticoes: dict[str, int] = {}
    for titulo in re.findall(r"^#{1,6}\s+(.+?)\s*#*\s*$", texto, re.M):
        titulo = re.sub(r"\[([^]]+)\]\([^)]+\)", r"\1", titulo)
        slug = re.sub(r"[^\w\- ]", "", titulo.lower()).replace(" ", "-")
        numero = repeticoes.get(slug, 0)
        repeticoes[slug] = numero + 1
        resultado.add(f"{slug}-{numero}" if numero else slug)
    return resultado


def verificar() -> dict:
    arquivos = sorted(ROOT.rglob("*.md"))
    problemas = []
    total = 0
    cache = {}
    for arquivo in arquivos:
        texto = texto_sem_codigo(arquivo.read_text(encoding="utf-8-sig"))
        for link in re.findall(r"\]\(([^)]+)\)", texto):
            link = link.strip().split(' "', 1)[0].strip("<>")
            uri = urlsplit(link)
            if uri.scheme or uri.netloc:
                continue
            total += 1
            destino = (arquivo.parent / unquote(uri.path)).resolve() if uri.path else arquivo
            erro = None
            if not destino.exists():
                erro = "arquivo ausente"
            elif uri.fragment and destino.suffix == ".md":
                if destino not in cache:
                    cache[destino] = ancoras(destino.read_text(encoding="utf-8-sig"))
                if unquote(uri.fragment) not in cache[destino]:
                    erro = "ancora ausente"
            if erro:
                problemas.append({"origem": arquivo.relative_to(ROOT).as_posix(),
                                  "destino": link, "erro": erro})
    chaves_unicas = {(p["destino"], p["erro"]) for p in problemas}
    return {"arquivos_markdown": len(arquivos), "links_locais": total,
            "problemas": problemas, "problemas_unicos": len(chaves_unicas)}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true", help="Emite detalhes em JSON")
    args = parser.parse_args()
    resultado = verificar()
    if args.json:
        print(json.dumps(resultado, ensure_ascii=True, indent=2))
    else:
        print(f"Markdown: {resultado['arquivos_markdown']}; links locais: {resultado['links_locais']}; "
              f"ocorrências com problema: {len(resultado['problemas'])}; "
              f"destinos problemáticos únicos: {resultado['problemas_unicos']}")
        for problema in resultado["problemas"]:
            print(f"{problema['origem']}: {problema['destino']} ({problema['erro']})")
    raise SystemExit(bool(resultado["problemas"]))
