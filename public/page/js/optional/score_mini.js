"undefined"==typeof window.Score&&(window.Score={}),$.extend(window.Score,{form_enabled:!0,form_admin:null,submit_operation:function(){if(this.form_admin=$("div#balise_image_admin").length>0,$("input#cb_not_ajax").is(":checked"))return!0;UI.spinner_start("Merci de patienter en attendant la fin de l'op\xe9ration. Elle peut prendre plusieurs dizaines de secondes en fonction de la taille de votre image.");var e=$("*#operation").val(),i=$("input#img_id").val();return Ajax.submit_form($("form#form_score"),$.proxy(Score,"retour_operation",e,i))},retour_operation:function(e,i,o){console.dir(o);var t=$("img#balise_img_edited_image");if("create_image"==e){var r=o.img_data;r?this.set_data_image_and_show(r,i):F.error("Un probl\xe8me est survenu\u2026 D\xe9sol\xe9.")}else"remove_image"==e&&($("li#li_img-"+i).remove(),t.hide(),this.reset_form());UI.spinner_stop(),console.log("<- retour_operation")},set_data_image_and_show:function(e){var i=$("form#form_score img#balise_img_edited_image");this.src=e.src,i.attr("src",e.src+"?"+e.updated_at),$("form#form_score input#img_id").val(e.id),$("form#form_score input#img_ticket").val(e.ticket),$("form#form_score input#img_affixe").val(e.affixe),i.show(),this.on_change_position_score(),$("div#cadre_score_reader").length&&($("div#cadre_score_reader").show(),this.set_submit_name("Modifier le score"),this.show_bouton_autre_image())},on_change_position_score:function(){$("input#code_balise_score").val(this.code_balise_score()),$("div#balise_image_admin").show(),$("div#exemple_commentaire").attr("class","score "+this.position_score())},position_score:function(){return $("form#form_score select#position_score").val()},code_balise_score:function(){var e="[score:";return e+=$("form#form_score input#img_id").val(),e+=":"+this.position_score(),e+="]"},reset_form:function(){$.map(["id","affixe","name","folder","ticket","src","left_hand","right_hand"],function(e){$('*[name="img_'+e+'"]').val("")}),this.hide_image(""),$("input#img_balise_img").val(""),this.set_submit_name("Cr\xe9er le score"),this.hide_bouton_autre_image()},show_bouton_autre_image:function(){$("a#btn_autre_image").show()},hide_bouton_autre_image:function(){this.form_admin||$("a#btn_autre_image").hide()},set_submit_name:function(e){$("input#score_btn_submit").val(e)},hide_image_if_no_src:function(){""==$("img#balise_img_edited_image").attr("src")&&this.hide_image()},hide_image:function(e){var i=$("img#balise_img_edited_image");"undefined"!=typeof e&&i.attr("src",e),i.hide()},MAX_SIGNS:300,compte_signes:function(){var e=$("textarea#img_right_hand").val().length+$("textarea#img_left_hand").val().length,i=this.MAX_SIGNS-e;0>i&&(i="<span class='warning bold'>Vous d\xe9passez de "+-i+" signes</span>"),$("div#signs_count").html(i)}}),$(document).ready(function(){Score.compte_signes(),Score.hide_image_if_no_src()});