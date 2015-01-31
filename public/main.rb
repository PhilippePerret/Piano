# encoding: UTF-8
require 'cgi'
require 'erb'

def w str
  STDOUT.write "#{str}\n"
end
def body
  <<-HTML
<div>Première ligne</div>
  HTML
end

class App
  def name
    "Le Cercle pianistique"
  end
  def view path
    path.concat(".erb") unless path.end_with? '.erb'
    real_path = File.join('.', 'public', 'page', path)
    ERB.new(File.read(real_path)).result(bind)
  end
  def stylesheets
    Dir["./public/page/css/**/*.css"].collect do |css|
      "<link rel='stylesheet' href='./#{relative_path css}' type='text/css' media='screen' charset='utf-8'>"
    end.join("\n")
  end
  def javascripts
    ""
  end
  def relative_path path
    path.sub(/^#{folder}\//, '')
  end
  def folder
    @folder ||= File.expand_path('.')
  end
  def bind; binding() end
end
app = App::new

cgi = CGI::new('html4')
cgi.out{
  cgi.html {
    ERB.new(File.read('./public/page/gabarit.erb').force_encoding('UTF-8')).result(app.bind)
    # cgi.head{ head } +
    # cgi.body{ body }
  }
}