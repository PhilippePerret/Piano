window.Mailing={decocher_all:function(){$('ul#followers li input[type="checkbox"]').map(function(){$(this)[0].checked=!1}),$('ul#membres li input[type="checkbox"]').map(function(){$(this)[0].checked=!1})},cocher_all:function(){$('ul#followers li input[type="checkbox"]').map(function(){$(this)[0].checked=!0}),$('ul#membres li input[type="checkbox"]').map(function(){$(this)[0].checked=!0})},cocher_membres:function(){this.decocher_all(),$('ul#membres li input[type="checkbox"]').map(function(){$(this)[0].checked=!0})},cocher_followers:function(){this.decocher_all(),$('ul#followers li input[type="checkbox"]').map(function(){$(this)[0].checked=!0})},on_define_id_new_article:function(){$("input#cb_annonce_new_article")[0].checked=!0}};