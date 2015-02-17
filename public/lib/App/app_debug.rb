# encoding: UTF-8
class App
  
  ##
  # Ajoute un message de débuggage
  #
  def debug str = nil
    if str.nil?
      # => Retourne le contenu du debug
      return "" if @debugs.nil? || (online? && false == cu.admin?)
      debug_str = @debugs.join("\n")
      "<div style='clear:both;'></div><pre id='debug'>#{debug_str}</pre>"
    else
      # => Ajoute un message de débug
      @debugs ||= []
      if str.class == String
        log str
        @debugs << str.gsub(/</, '&lt;')
      elsif str.respond_to? :backtrace
        # => Une erreur envoyée
        bckt = str.backtrace.join("\n")
        merr = str.message
        log "#{merr}\n\n#{bckt}\n\n"
        merr.gsub!(/</, '&lt;')
        @debugs << "#{merr}\n\n#{bckt}"
      else
        str = str.inspect
        log str
        @debugs << str
      end
    end
  end
  
  def log str
    nowh = Time.now.strftime("%d %m %Y - %H:%M")
    reflog.write "--- [#{nowh}] #{str}\n"
  end
  def reflog
    @reflog ||= File.open(log_path, 'a')
  end
  def log_path
    @log_path ||= begin
      `if [ ! -d "./tmp/log" ];then mkdir -p "./tmp/log";fi`
      nowt = Time.now.strftime("%Y%m%d")
      File.join('.', 'tmp', 'log', "debug-#{nowt}.log")
    end
  end
  
end