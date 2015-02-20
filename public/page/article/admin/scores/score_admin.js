if('undefined'==typeof window.Score){window.Score={}}
$.extend(window.Score,{
	onchange_operation:function(op){
		var btn ;
		switch(op){
		case 'create_image':
			btn = "Créer cette partition";
			break
		case 'remove_image':
			btn = "Détruire cette partition";
			break
		}
		$('input[type="submit"]#btn_exec_operation').val(btn) ;
	},
	
	/**
	  * Retourne le code à copier-coller.
		* Noter que cette méthode surclasse la méthode générale
		* pour l'user.
	  *  
	  */
	code_balise_score:function(){
		return "<img src='"+this.src+"' />" ;
	},
	
	
})
