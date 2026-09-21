void main(){

  var total = 0;
  for(var i = 1; i <= 4; i++){
    if(i == 3) break;
    // if(i == 3) continue;
    total += i * 10;
  }

print(total);

}

