/*
 *  Script pour Score commun à l'user et à l'admin
 *  
 */
if('undefined'==typeof window.Score){window.Score={}}
$.extend(window.Score,{
	form_enabled: true,
	/*
	 *  Méthode appelée quand on soumet le formulaire de
	 *  création de l'image.
	 *
	 */
	submit_operation:function(){
		console.log("-> submit_operation");
		if($('input#cb_not_ajax').is(':checked')) return true ;
		UI.spinner_start("Merci de patienter en attendant la fin de l'opération. Elle peut prendre plusieurs dizaines de secondes en fonction de la taille de votre image.");
		var op 				= $('select#operation').val();
		var image_id 	= $('input#image_id').val();
		return Ajax.submit_form($('form#form_score'), $.proxy(Score, 'retour_operation', op, image_id));
	},
	retour_operation:function(op, image_id, rajax){
		console.log("-> retour_operation");
		var img = $('img#balise_img_edited_image') ;
		var img_data = rajax.img_data ;
		if(op == 'create_image'){
			// Afficher l'image
			this.set_data_image_and_show(img_data, image_id) ;
		} else if (op == 'remove_image'){
			// Destruction de l'image
			$("li#li_img-" + image_id).remove();
			img.hide();
			this.reset_form();
		}
		UI.spinner_stop();
		console.log("<- retour_operation");
	},
	/*
	 *  Règle les données de l'image après sa création
	 *  
	 */
	set_data_image_and_show:function(img_data, image_id){
		var img = $('img#balise_img_edited_image') ;
		img.attr('src', img_data.src + "?" + img_data.updated_at) ;
		$('input#image_id').val(image_id || img_data.id) ;
		$('input[name="img_ticket"]').val(img_data.ticket) ;
		img.show();
	},
	reset_form:function(){
		$.map(['id', 'affixe', 'name', 'folder', 'ticket', 'src', 'left_hand', 'right_hand'], function(id){
			$('*[name="img_'+id+'"]').val("") ;
		})
		this.hide_image('');
	},
	hide_image_if_no_src:function(){
		if($('img#balise_img_edited_image').attr('src') == "") this.hide_image();
	},
	hide_image:function(src){
		var img = $('img#balise_img_edited_image') ;
		if('undefined'!=typeof src){ img.attr('src', src) }
		img.hide() ;
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
})

$(document).ready(function(){
	Score.compte_signes();
	Score.hide_image_if_no_src();
})