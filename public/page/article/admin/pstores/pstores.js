window.PStore = {
	set_operation:function(op){
		console.log("Mise opération : " + op) ;
		$('form#form_pstore input[name="operation"]').val(op);
	},
	/*
	 *  Soumet le formulaire
	 *  
	 */
	submit:function(){
		$('form#form_pstore').submit();
	}
}