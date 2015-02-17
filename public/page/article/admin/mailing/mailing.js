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
	},
	
	/*
	 * Méthode appelée quand on définit un ID d'article dont il faut annoncer
	 * la publication
	 *  
	 */
	on_define_id_new_article:function(inputtext){
		// On s'assure que la case à cocher est bien cocher
		$('input#cb_annonce_new_article')[0].checked = true
	}
}