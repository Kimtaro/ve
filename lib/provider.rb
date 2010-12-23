class Sprakd
  class Provider
  
    # Interface, to be implemented by providers
  
    def provides
    end
  
    def start!
    end
  
    def works?
    end

    def parse
    end

  end  
end

class Sprakd
  class Parse
    
    # TODO
    def as_json
    end
    
  end
end
