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
		var op 				= $('*#operation').val();
		var image_id 	= $('input#image_id').val();
		return Ajax.submit_form($('form#form_score'), $.proxy(Score, 'retour_operation', op, image_id));
	},
	retour_operation:function(op, image_id, rajax){
		console.dir(rajax);
		var img = $('img#balise_img_edited_image') ;
		if(op == 'create_image'){
			// Afficher l'image
			var img_data = rajax.img_data ;
			if(img_data){
				this.set_data_image_and_show(img_data, image_id) ;
			}else{
				F.error("Un problème est survenu… Désolé.");
			}
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
		var img = $('form#form_score img#balise_img_edited_image') ;
		img.attr('src', img_data.src + "?" + img_data.updated_at) ;
		$('form#form_score input#img_id').val(img_data.id) ;
		$('form#form_score input#img_ticket').val(img_data.ticket) ;
		$('form#form_score input#img_affixe').val(img_data.affixe) ;
		img.show();
		if($('div#cadre_score_reader').length){
			/** Afficher le cadre qui contient tout ce qu'il faut pour 
			  * insérer l'image dans le commentaire */
			$('div#cadre_score_reader').show();
			/** Régler la balise à copier-coller */
		  this.on_change_position_score() ;
			/** Changer le nom du bouton */
			this.set_submit_name("Modifier le score") ;
			/** Faire apparaitre le bouton pour créer une nouvelle image */
			this.show_bouton_autre_image();
		}
	},
	
	/**
	  * Méthode appelée quand l'utilisateur change la position
	  * de l'image.
	  */
	on_change_position_score:function(){
	  $('input#code_balise_score').val(this.code_balise_score()) ;
	},
	/**
	  * Retourne le code de la balise reader à copier dans le
		*	texte du commentaire.
	  *  
	  */
	code_balise_score:function(){
		var code = "[score:" ;
		code += $('form#form_score input#img_id').val() ;
		code += ":" + $('form#form_score select#position_score').val() ;
		code += "]" ;
		return code ;
	},
	reset_form:function(){
		$.map(['id', 'affixe', 'name', 'folder', 'ticket', 'src', 'left_hand', 'right_hand'], function(id){
			$('*[name="img_'+id+'"]').val("") ;
		})
		this.hide_image('');
		$('input#img_balise_img').val("");
		this.set_submit_name("Créer le score") ; 
		this.hide_bouton_autre_image();
	},
	
	show_bouton_autre_image:function(){
		$('a#btn_autre_image').show();
	},
	hide_bouton_autre_image:function(){
		$('a#btn_autre_image').hide();
	},
	/**
	  * Méthode pour régler le nom du bouton submit
	  *  
	  */
	set_submit_name:function(btn_name){
		$('input#score_btn_submit').val( btn_name ) ;
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