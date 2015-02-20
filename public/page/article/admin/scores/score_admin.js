if('undefined'==typeof window.Score){window.Score={}}
$.extend(window.Score,{
	onchange_operation:function(op){
		var btn ;
		switch(op){
		case 'create_image':
			btn = "Créer cette partition";
			break
		case 'remove_image':
			btn = "Détruire cette partition";
			break
		}
		$('input[type="submit"]#btn_exec_operation').val(btn) ;
	},
	
})
