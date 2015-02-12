# encoding: UTF-8
=begin

Class App

=end
class App
  
  HOST_ONLINE =   "piano.alwaysdata.net"
  FULL_URL    =    "http://#{HOST_ONLINE}/"
  
  class << self
    
    ##
    ## Instance App courante, qui gère tout le site
    ##
    attr_accessor :current
    
    def offline?
      @is_offline = !online? if @is_offline === nil
      @is_offline
    end
    def online?
      @is_online = (ENV['HTTP_HOST'] != "localhost") if @is_online === nil
      @is_online
    end
    
  end
end