

void main(){
  final tags = <String>{'dart', 'flutter', 'dart'}; // vai considerar como dois elementos
  final minutos = <String, int>{'Dart': 40, 'Git': 25};

  print(tags);
  print(minutos);

  /**Exemplo mínimo */
  final dias = <String>{'seg', 'ter', 'seg'}; //set
  final metas = <String, int>{'Dart': 120};
  metas['Flutter'] = 90;
  print(dias); // {seg, ter}
  print(metas['Dart']);
  print(metas['Git']); // null

}