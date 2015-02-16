class Tests
  class << self
    attr_reader :variables
    
    ##
    # Définit une ou des variables
    #
    def set_var hdata
      @variables ||= {}
      @variables.merge! hdata
    end
    
    ##
    # Retourne une variable définie par `set_var'
    #
    def get_var key
      @variables ||= {}
      @variables[key]
    end
    
  end # << self
end