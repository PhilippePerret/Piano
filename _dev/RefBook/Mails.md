#Mails


* [Envoi d'un mail à un membre/follower](#send_mail_to_user)
* [Utiliser des vues pour les mails](#utiliser_vues_pour_mail)
* [Rédaction du fichier ERB du mail](#redaction_du_fichier_erb_du_mail)
  * [Liens vers un article ou une section](#lien_vers_article_ou_section)


<a name='send_mail_to_user'></a>
##Envoi d'un mail à un membre/follower

Pour envoyer un message à un membre ou un follower, il suffit d'utiliser la méthode `send_mail`&nbsp;:

    u = User::get_as_follower "<son mail>"
    data_mail = {
      subject:    "<le sujet>",
      message:    "<le message>"
    }
    u.send_mail data_mail

<a name='utiliser_vues_pour_mail'></a>
##Utiliser des vues pour les mails

Le plus simple, pour le contenu des messages de mails, est d'utiliser des vues. Il suffit alors de définir les data du mail par&nbsp;:

    data_mail {
      subject:    "<Le sujet du mail>",
      message:    app.view('path/depuis/folder/page/vue_mail'[, <bindee>])
    }

<a name='redaction_du_fichier_erb_du_mail'></a>
##Rédaction du fichier ERB du mail

<a name='lien_vers_article_ou_section'></a>
###Liens vers un article ou une section

On peut utiliser ces deux méthodes pour faire un lien vers un article ou une section du site&nbsp;:

    <%= link_to "<titre>", "<id/path/article>", {mail: true}  =>
    <%= link_to_article "<id/path/article>", mail: true       =>

*Noter que `mail: true` permet de retourner 1/ un lien `<a>` au lieu d'un formulaire et d'utiliser des URL complètes.*

