if('undefined'==typeof window.UI){ window.UI = {} }
$.extend(window.UI,{
	
	/*
	 *  Classe UI.Audio
	 *  ---------------
	 *	Gestion des fichiers audios
	 *
	 * Le plus simple pour avoir des éléments HTML cohérents est
	 * d'utiliser la méthode helper `image' (ruby)
	 *
	 * Cf. RefBook > Partitions.md
	 *
	 */
	Audio:{
		
		objets_audio: {}, // Liste des objets audio instanciés
		
		new:function(audio_id){
			if('undefined' == typeof this.objets_audio[audio_id]){
				 this.objets_audio[audio_id] = new ObjAudio(audio_id) ;
			}
			return this.objets_audio[audio_id] ;
		}
		
	}
	
});

window.ObjAudio = function(id){
	this.objet_audio = $('audio#'+id)[0] ;
	this.button_play = $('a#btn_audio'+id) ;
	this.playing = false ;
	this.observe() ;
}
$.extend(window.ObjAudio.prototype,{
	on_end:function(){
		this.stop() ;
		F.show("Fin atteinte");
	},
	play:function(){
		if(this.playing == true){
			this.stop();
		}else{
			this.objet_audio.play();
			this.playing = true ;
			this.set_button("Arrêter") ;
		}
	},
	stop:function(){
		this.objet_audio.pause();
		this.objet_audio.currentTime = 0 ;
		this.playing = false ;
		this.set_button("Rejouer") ;
	},
	set_button:function(name){this.button_play.html(name)},
	on_waiting:function(){
		this.set_button("...")
	},
	on_canplay:function(){
		this.set_button("Rejouer");
	},
	on_loadstart:function(){
		this.set_button("Chargement…") ;
	},
	
	/*
	 *  Place les observers sur l'objet audio.
	 *  
	 */
	observe:function(){
		var me = this ;
		$(this.objet_audio).
			bind('ended', $.proxy(me, 'on_end')).
			bind('waiting', $.proxy(me, 'on_waiting')).
			bind('canplay', $.proxy(me, 'on_canplay')).
			bind('loadstart', $.proxy(me, 'on_loadstart')) ;
		
	}
})