# encoding: UTF-8
class App
  
  def no_error?
    @errors.nil? || @errors.empty?
  end
  
  def flash message
    @messages ||= []
    @messages << message
  end
  
  def error err_message
    @errors ||= []
    @errors << err_message
  end
  
  def messages
    return "" if @messages.nil? && @errors.nil?
    <<-HTML
<section id="flash">
  #{div_messages}
  #{div_errors}
</section>
    HTML
  end
  
  def div_messages
    return "" if @messages.nil? || @messages.empty?
    c = "<div id='messages'>"
    c << @messages.collect { |mess| "<div>#{mess}</div>" }.join("")
    c << '</div>'
    return c
  end
  def div_errors
    return "" if @errors.nil? || @errors.empty?
    c = "<div id='errors'>"
    c << @errors.collect {|mess| "<div>#{mess}</div>" }.join("")
    c << '</div>'
    return c
  end
end