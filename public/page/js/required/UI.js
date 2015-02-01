if('undefined'==typeof window.UI){ window.UI = {} }
$.extend(window.UI,{
	
	/**
		* Méthode appelée au chargement de la page pour faire apparaitre
		* les boutons lentement
		*/
	unshade_boutons:function(){
		$('section#rmargin').animate({ 'opacity': 1 }, 4000)
	}
	
})