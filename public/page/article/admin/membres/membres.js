window.Membres = {
	
	/*
	 *  Reset le formulaire d'édition du membre (vide tous les champs)
	 *  
	 */
	reset_form:function(){
		var e ;
		// form#user_edit_form > div ci-dessous permet de ne pas
		// traiter la définition de 'operation' et 'article'
		$('form#user_edit_form > div.row *').map(function(){
			e = $(this);
			switch(e[0].tagName){
			case 'TEXTAREA':
			case "INPUT":
				if(e.attr('type') != "submit"){
					e.val("")
				}
				break;
			default:
				// Ne rien faire
			}
		});
		$('select[name="user_grade"]').val("veilleur");
	}
}