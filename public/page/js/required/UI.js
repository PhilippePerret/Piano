if('undefined'==typeof window.UI){ window.UI = {} }
$.extend(window.UI,{
	
	/**
		* Méthode qui permet d'ouvrir une image.
		* Cette image est affichée réduite pour tenir dans la page, dans un
		* DIV de class "openable_image" qui est envoyé en premier paramètre
		* de cette méthode.
		*
		* Note: C'est l'ajout de la classe 'opened' qui traite le changement
		* de dimension, donc il faut que la class CSS le gère en définissant
		*		div.openable_image.opened (et 'img' à l'intérieur)
		*	C'est le width qui doit être affecté, passant de 'auto' (ouvert) à
		*	'95%' (fermé) ou autre valeur
		*/
	toggle_image:function(divimg){
		divimg = $(divimg) ;
		var is_opened = divimg.hasClass('opened') ;
		// var w = is_opened ? '95%' : 'auto' ;
		if(is_opened){divimg.removeClass('opened')}else{divimg.addClass('opened')}
		// divimg.css( 'width', w ) ;
		// divimg.find('img').css( 'width' , w ) ;
		if(!is_opened/*donc : ouvert maintenant*/){
			var w = divimg.find('img').width();
			divimg.css({'min-width':w+'px','width':w+'px'});
			$('section#rmargin').css('z-index', '-1');
		}else{
			divimg.css({'min-width':'','width':''});
			$('section#rmargin').css('z-index', '0');
		}
	},
	
	/**
		* Méthode appelée au chargement de la page pour faire apparaitre
		* les boutons lentement
		*/
	unshade_boutons:function(){
		$('section#rmargin').animate({ 'opacity': 1 }, 4000)
	},
	
	/*
	 *  Pour gérer un "spinner" dans la page
	 *
	 *	Pour fonctionner, le spinner doit se trouver dans un div
	 *	d'id #div_spinner
	 *	Il doit contenir un p#spinner_message si un message doit
	 * 	être défini (premier argument)
	 *
	 *	Si la page contient un élément .fade_on_spinner, c'est le 
	 *	l'élément qui sera atténué pendant le spinner.
	 *  
	 */
	spinner_start:function(message){
		$('div#div_spinner').show();
		this.init_background_color_spinner = $('*.fade_on_spinner').css('background-color');
		$('*.fade_on_spinner').animate({opacity: 0.2, 'background-color': "#CCC"})
		if('undefined'!=typeof message){$('p#spinner_message').html(message)}
	},
	spinner_stop:function(){
		$('div#div_spinner').hide();
		$('*.fade_on_spinner').animate({opacity: 1, 'background-color': this.init_background_color_spinner})
	}
	
})