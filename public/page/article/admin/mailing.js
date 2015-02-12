window.Mailing = {
	/**
		* Méthode qui décoche tous les followers
		*/
	decocher_all_followers:function(){
		$('ul#followers li input[type="checkbox"]').map(function(){
			$(this)[0].checked = false ;
		})
	},
	cocher_all_followers:function(){
		$('ul#followers li input[type="checkbox"]').map(function(){
			$(this)[0].checked = true ;
		})
	}
}