window.NewSujet = {
	
	onfocus_path:function(){
		window.onkeypress = this.onkeypress_on_path ;
		// Si c'est le tout premier focus, on relève la liste
		// des dossiers
		if(this.get_path() == ""){
			this.get_suite_path_of("", $.proxy(this, 'show_dossiers'))
		}
	},
	onblur_path:function(){
		window.onkeypress = null ;
	},
	
	get_suite_path_of: function(segpath, method_suivre){
		Ajax.send({o: 'get_suite_path_of', o1: segpath, onreturn: method_suivre})
	},
	
	onchoose_dossier:function(dossier){
		var cur_path = this.get_path();
		cur_path += dossier + "/" ;
		this.set_path(cur_path);
		this.get_suite_path_of(cur_path, $.proxy(this, 'show_dossiers') ) ;
	},
	/*
		*	Afficher les dossiers du dossier courant
		*/
	show_dossiers:function(rajax){
		$('select#dossiers').html("");
		$('select#dossiers').append('<option value="">Choisir le dossier…</option>');
		$.map(rajax.dossiers, function(dname){
			$('select#dossiers').append('<option value="'+dname+'">'+dname+'</option>');
		})
	},
	/*
	 *  Remplit le path dans art_path avec le path donné
	 *  par ajax
	 */
	fill_path:function(rajax){
		this.show_dossiers(rajax);
		if(rajax.unfound){
			Flash.show("Path introuvable.");
		}else{
			this.set_path(rajax.path) ;
		}
	},
	
	set_path:function(path){
		$('input[name="art_path"]').val(path);
	},
	get_path:function(){
		return $('input[name="art_path"]').val();
	},
	
	onkeypress_on_path:function(ev){
		if(ev.keyCode == KeyEvent.DOM_VK_TAB){
			console.log("Touche TAB tapée") ;
			NewSujet.get_suite_path_of(NewSujet.get_path(), $.proxy(NewSujet,'fill_path'))
			return false ;
		}
		return true ;
	}
	
}