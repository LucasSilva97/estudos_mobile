void main() {
  const String versaoFlutter = '3.47.1';
  const String versaoDart = '3.13.1';
  const String canal = 'stable';

  const String nomeApp = 'Foco';
  const String idPacote = 'br.com.estudos.foco';

  const String saidaApk = 'build/app/outputs/flutter-apk/app-release.apk';
  const String saidaAab = 'build/app/outputs/bundle/release/app-release.aab';
  const String saidaArchive = 'build/ios/archive/Runner.xcarchive';
  const String saidaIpa = 'build/ios/ipa/<nome>.ipa';

  const String camadas = '''
          Você escreve  ->  Dart (linguagem)
                  usa
              Framework Flutter (widgets, layout, Material 3)
                  roda sobre
              Engine C++ + Impeller/Skia (desenha os pixels)
                  hospedada por
              Embedder (Android / iOS / Windows)'
        ''';

  print('=== ECOSSISTEMA DO CURSO ===');
  print('Flutter $versaoFlutter (canal $canal) traz o Dart $versaoDart dentro.');
  print('');
  print(camadas);
  print('');

  print('=== APP FINAL ===');
  print('Nome: $nomeApp');
  print('Identificador: $idPacote');
  print('  - no Android esse valor é o applicationId');
  print('  - no iOS esse mesmo valor é o Bundle Identifier');
  print('');

  print('=== ARTEFATOS ===');
  print('[Android] APK instalavel : $saidaApk');
  print('[Android] AAB para a Play: $saidaAab');
  print('[iOS]     Archive        : $saidaArchive');
  print('[iOS]     IPA assinado   : $saidaIpa');
  print('');

  // Um booleano guarda verdadeiro ou falso.
  const bool estouNoWindows = true;
  const bool tenhoMac = false;

  print('=== O QUE EU CONSIGO FAZER HOJE ===');
  print('Windows 11: $estouNoWindows  ->  APK e AAB: sim.');
  print('Tenho Mac : $tenhoMac  ->  IPA: nao, exige macOS + Xcode.');
  print('Ler e entender o processo iOS: sempre possivel.');
}