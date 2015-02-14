# encoding: UTF-8
=begin

C'est ce module qui doit être appelé pour envoyer des mails

=end
App::current::require_library 'mail-2.0'

# ---------------------------------------------------------------------
#
# Pour définir les éléments graphiques du mail
#
class Mail
  class << self
    def body_style
      <<-EOC
padding: 0;
margin: 2em;
font-family:serif;
font-size:17pt;
width: 680px;
      EOC
    end
    def styles_css
      <<-EOC
a {
  text-decoration: none;
  color: tomato;
}
div#logo{
  font-size: 24pt;
  padding: 1em 0;
  border-bottom: 2px solid;
  margin-bottom: 2em;
}
section#footer{
  margin-top: 2em;
  border-top:1px solid;
  padding-top:24px;
}
.center{text-align: center}
.bold{font-weight: bold}
      EOC
    end
    def before_subject
      "#{App::current::short_name} -- "
    end
    def header
      <<-HTML
  <div id='logo'>#{App::current::name}</div>
      HTML
    end
    def footer
      <<-HTML
<section id='footer'>
  <a href="http://piano.alwaysdata.net">#{App::current::name}</a>
</section>
      HTML
    end
  end
end