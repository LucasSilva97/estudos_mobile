void main(){
  for(var i = 1; i <= 30; i++){
   
    if (i % 3 == 0 && i % 5 == 0){
      print('$i é DartFlutter');
    } else if (i % 3 == 0){
      print('$i é Dart');
    } else if  (i % 5 == 0){
      print('$i é Flutter');
    } else{
      print('$i Sem classificação');
    }

  }
}