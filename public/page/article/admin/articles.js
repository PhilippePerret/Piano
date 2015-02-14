if('undefined'==typeof window.Articles){window.Articles={}}
$.extend(window.Articles,{
	
	/**
		* Méthode qui règle l'état des articles
		*/
	set_etat_articles:function(){
		var etat;
		$('ul#articles > li').map(function(){
			etat = $(this).attr('data-etat') ;
			$(this).find('select[name="etat"]').val(etat) ;
		})
	},
	
	/**
		* Méthode appelée quand on change l'état d'un article
		*
		*/
	onchange_etat:function(select){
		var article_id 	= $(select).parent().attr('data-id') ;
		var li_article 	= $('li#li-'+article_id) ;
		var new_etat		= $(select).val() ;
		li_article.attr('data-etat', new_etat) ;
		Ajax.send({o: 'change_etat_article', o1: article_id, o2: new_etat})
	},
	
	/**
		* Méthode qui permet de détruire les données de l'article dans
		* le pstore (mais pas l'article lui-même)
		*/
	remove_data:function(btn){
		var article_id = $(btn).attr('data-id') ;
		if(confirm("Voulez-vous vraiment détruire les données pstore de l'article "+article_id+" (mais pas l'article lui-même)?")){
			Ajax.send({o: 'remove_data_article', o1: article_id, onreturn: $.proxy(Articles,'retour_remove_data', article_id)})
		}
	},
	retour_remove_data:function(article_id, rajax){
		if(rajax.ok){
			$('li#li-'+article_id).remove();
		}
	}
	
})
$(document).ready(function(){
	Articles.set_etat_articles();
})