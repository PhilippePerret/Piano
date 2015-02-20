if('undefined'==typeof window.UI){ window.UI = {} }
$.extend(window.UI,{
	
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