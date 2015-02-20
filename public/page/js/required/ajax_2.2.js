/**
  * @module ajax.js
  * @version 2.2 (février 2015)
  *
  * Dépendances
  *   * Nécessite l'objet Flash pour l'affichage des messages d'erreur
  *     Doit obligatoirement retourner false (requête abandonnée) ou true
	*		Si on soumet des formulaires par ajax avec `submit_form' ou par
	*		on_submit_form :
  *			* Requiert Object_extension.js
	*			* Requiert String.js (pour capitalize())
  */
window.Ajax = {
	url:'./index.rb',
  onreturn:null,
  
  /**
    * Procéder à une requête ajax
    * Cf. la section Ajax dans le manuel
    * @method send
    * @param  {Hash}      data      Données à transmettre au programme serveur
    * @param  {Function}  onreturn  Méthode pour suivre
    */
  send:function( data ){
    if(this.before_send(data) == false) return;
    data.ajx = 1 ;
    this.onreturn = data.onreturn ;
    delete data.onreturn ;
    Flash.clean('Ajax.send');
    Flash.message("Opération en cours…");
    $.ajax({
      url     : this.url,
      type    : 'POST', 
      data    : data,
      success : $.proxy(this.on_success, this),
      error   : $.proxy(this.on_error, this)
      });
  },
  on_success:function(data, textStatus, jqXHR){
    Flash.clean('Ajax.on_success');
    this.traite_messages_retour( data );
    this.traite_css_retour( data.css ) ;
    if('function' == typeof this.onreturn) this.onreturn(data);
    return true;
  },
  on_error:function(jqXHR, errStatus, error){
    Flash.clean('Ajax.on_error');
    Flash.error( error );
  },
  /**
    * Méthode propre à l'application pour vérfier les données ou les modifier
    * @method before_send
    * @param  {Object} data Les données envoyées à send
    * @return {Boolean} True si la requête peut se faire, false otherwise
    */
  before_send:function(data)
  {
    // var route_isnt_defined = (undefined == data.r)
    // if(route_isnt_defined){ return F.error("Les données envoyées par Ajax doivent absolument définir `r', la méthode de router à utliser. Si c'est un champ de formulaire, ajouter le champ hidden de name 'r'.");}
    return true;
  },
  
  /**
    * Traitement spécial des propriétés `message' et `error' si elles
    * existent dans le retour ajax
    * @method traite_messages_retour
    * @param {Object} data    Hash retourné par le serveur
    */
  traite_messages_retour:function(data)
  {
    if('undefined' == typeof data){ return }
    if('undefined' != typeof data.message){Flash.message(data.message);delete data.message;}
    if('undefined' != typeof data.error){Flash.error(data.error);delete data.error;}
		/**
			* Pour les applications qui n'utilisent pas un flash flottant
			*/
		$('section#flash').css({position: 'fixed', top: '8px', left: '30%'}) ;
  },
  
  /**
    * Si les données de retour Ajax contiennent la propriété `css'
    * ce sont des feuilles de style à ajouter dans la page
    *
    */
  traite_css_retour:function(arr_css){
    if('undefined' == typeof arr_css || arr_css == null) return ;
    $.map(arr_css, function(path_css, icss){
      $('head').append("<link rel='stylesheet' type='text/css' href='"+path_css+"' charset='utf-8' />")
    })
  },
  /**
    * Pour soumettre une formulaire
    * @method submit_form
    * @param {String}   form_id   ID html du formulaire (sans "form#") OU le formulaire lui-même
    * @param {Function} fn_return [Optionnel] Fonction de retour, appelée au retour de la 
    *                             soumission avec le résultat
    */
  submit_form:function(form_id, fn_return)
  {
		return this.on_submit_form( form_id, fn_return ) ;
  },
  /**
    * Les formulaires possédant l'attribut ajax="1" sont observés
    * et passent par ici. Si tout se passe bien ici, le formulaire est
    * soumis en Ajax, sinon le formulaire est soumis normalement.
    * 
    * Si la route `r' est définie dans le formulaire elle doit correspondre
		* à la méthode de traitement du retour Ajax. Par exemple :
    *   r = "narration/show"
    *   => que la route ruby sera la méthode 'show' de l'objet Narration
    *   => que la méthode de traitement du retour Ajax en javascript sera
    *      aussi la méthode 'show' de l'objet Narration (noter la capitale)
    * Sinon, la fonction de retour peut être définie dans le paramètre
		*	'onreturn' avec la valeur "objet/méthode"
		* Sinon, aucune méthode de retour ne sera appelée.
		*
		* +fn_return+ est défini quand c'est la méthode `submit_form'
		* qui est invoquée
    */
  on_submit_form:function(form, fct_return){
    try {
      var arr     = $(form).serializeArray() ;
      var hdata   = hash( arr ) ;
			var droute, dreturn, fct_return ;
			if('undefined' != typeof hdata.r){
	      droute  = hdata.r.split('/') ;
			}
			if( ! fct_return ){
	      if('undefined' == typeof hdata.onreturn) {
					// Fonction de retour définie par "r"
	        dreturn = droute ;
	      } else {
	        // Fonction de retour stipulée explicitement
	        dreturn = hdata.onreturn.split('/') ;
	      }
				if( dreturn ){
		      var objet   = dreturn[0].capitalize() ;
		      var method  = dreturn[1] ;
		      fct_return 	= $.proxy(window[objet], method) ;
				}
			}
      hdata.onreturn 	= fct_return ;
			hdata.ajax 			= "1" ;
			hdata.ajx				= "1" ;
      this.send( hdata ) ;
      return false ; // pour court-circuiter le formulaire
    } catch (err) {
      // Si une erreur s'est produite, on charge la page normalement
      if(console) console.error( err ) ;
      F.error("Une erreur est survenue : " + err) ;
      return false ;
    }
  }
}