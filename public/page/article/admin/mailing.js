window.Mailing = {
	/**
		* Méthode qui décoche tous les followers
		*/
	decocher_all:function(){
		$('ul#followers li input[type="checkbox"]').map(function(){
			$(this)[0].checked = false ;
		})
		$('ul#membres li input[type="checkbox"]').map(function(){
			$(this)[0].checked = false ;
		})
	},
	cocher_all:function(){
		$('ul#followers li input[type="checkbox"]').map(function(){
			$(this)[0].checked = true ;
		})
		$('ul#membres li input[type="checkbox"]').map(function(){
			$(this)[0].checked = true ;
		})
	},
	cocher_membres:function(){
		this.decocher_all();
		$('ul#membres li input[type="checkbox"]').map(function(){
			$(this)[0].checked = true ;
		})
	},
	cocher_followers:function(){
		this.decocher_all();
		$('ul#followers li input[type="checkbox"]').map(function(){
			$(this)[0].checked = true ;
		})
	}
}