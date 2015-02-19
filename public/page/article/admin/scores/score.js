window.Score = {
	
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
	
	/*
	 *  Méthode faisant le compte des signes déjà entrés.
	 *  
	 */
	MAX_SIGNS: 300,
	compte_signes:function(){
		var total = $('textarea#img_right_hand').val().length +
		$('textarea#img_left_hand').val().length ;
		var reste = this.MAX_SIGNS - total ;
		if (reste < 0){reste = "<span class='warning bold'>Vous dépassez de "+(-reste)+' signes</span>'}
		$('div#signs_count').html(reste) ;
	}
}
$(document).ready(function(){
	Score.compte_signes();
})