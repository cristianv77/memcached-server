class Item
    attr_accessor :key
    attr_accessor :value
    attr_accessor :ttl
    attr_accessor :expiration
    attr_accessor :size
    attr_accessor :flags
    attr_accessor :cas
  
    def initialize(key,flags,ttl,size,value)
      @key = key
      @flags = flags
      @ttl = ttl
      @size = size
      @value = value
      @cas = 1
      ttl === 0 ? @expiration = Time.now + (60*60*24*365*10): @expiration = Time.now + ttl
    end
  end