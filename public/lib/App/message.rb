# encoding: UTF-8
class App
  
  attr_reader :messsages, :errors # surtout pour tests
  
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
    return "" unless has_messages?
    c = "<div id='messages'>"
    c << @messages.collect { |mess| "<div>#{mess}</div>" }.join("")
    c << '</div>'
    return c
  end
  def div_errors
    return "" unless has_errors? 
    c = "<div id='errors'>"
    c << @errors.collect {|mess| "<div>#{mess}</div>" }.join("")
    c << '</div>'
    return c
  end
  
  
  def has_messages? mess_expected = nil
    no_messages = @messages.nil? || @messages.empty?
    if mess_expected.nil?
      return !no_messages
    else
      return false if no_messages
      @messages.each do |mess|
        return true if mess == mess_expected
      end
      return false
    end
  end
  alias :has_message? :has_messages?
  
  def has_errors? err_expected = nil
    no_errors = @errors.nil? || @errors.empty?
    if err_expected.nil?
      return !no_errors
    else
      return false if no_errors
      @errors.each do |mess_err|
        return true if mess_err == err_expected
      end
      return false
    end
  end
  alias :has_error? :has_errors? # pour les tests
  
end