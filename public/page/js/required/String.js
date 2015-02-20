String.prototype.capitalize = function(){
  if(this == "") return "" ;
  else if (this.length == 1) return this.toUpperCase() ;
  else {
    return this.substr(0,1).toUpperCase() + this.substr(1) ;
  }
}

String.prototype.is_number = function(){
	return this.replace(/[0-9]/g,'') == "" ;
}
String.prototype.is_float = function(){
	return this.replace(/[0-9\.]/g,'') == "" ;
}