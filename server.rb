#!/usr/bin/env ruby
require "socket"

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

class Server
    attr_accessor :port
    attr_accessor :data
    attr_accessor :clients
    attr_reader :sock
  
    def initialize()
      thiago = Item.new("1",0,0,0,"thiago")
      tito = Item.new("2",0,60,0,"tito")
      topo = Item.new("3",0,0,0,"topo")
      @data = {"1" => thiago, "2" => tito, "3" => topo}
      @clients = []
    end

    def interprete(client, line)
      array = line.split(" ")
      command = array[0]
      case command
        when "get"
          get(client,array[1].split(","))
        when "gets"
          getcas(client,array[1].split(","))
        when "set"
          set(client,array[1],array[2],Integer(array[3]),Integer(array[4]), array[5])
        when "add"
          add(client,array[1],array[2],Integer(array[3]),Integer(array[4]), array[5])
        when "replace"
          replace(client,array[1],array[2],Integer(array[3]),Integer(array[4]), array[5])
        when "append"
          append(client,array[1],array[2],Integer(array[3]),Integer(array[4]),array[5])
        when "prepend"
          prepend(client,array[1],array[2],Integer(array[3]),Integer(array[4]), array[5])
        when "cas"
          cas(client,array[1],array[2],Integer(array[3]),Integer(array[4]), Integer(array[5]), array[6])
      end
    end

    def depurate()
      time = Time.now
      @data.each do |key, item|
        if item.expiration < time
          @data.delete(key)
          puts "DELETE #{item.value}"
        end
      end
    end

    def connect()
      @pid = Process.pid
      server = TCPServer.open(2000)    
      puts("RUNNING SERVER")
      loop {                           
        Thread.start(server.accept) do |client|
          client.puts(Time.now.ctime)   
          while line = client.recv(200)
            depurate()
            puts line
            interprete(client,line)
          end
        end
      }
    end
  
    def get(client,keys)
      keys.each do |key|
        if @data[key]
          item = @data[key]
          client.puts "VALUE #{key} #{item.flags} #{item.size}"
          client.puts "#{item.value}"
        end
      end
      client.puts "END"
    end

    def getcas(client,keys)
      keys.each do |key|
        if @data[key]
          item = @data[key]
          client.puts "VALUE #{key} #{item.flags} #{item.size} #{item.cas}"
          client.puts "#{item.value}"
        end
      end
      client.puts "END"
    end
  
    #set mykey <flags> <ttl> <size>
    def set(client,key, flags, ttl, size, datablock)
      item = Item.new(key,flags,ttl,size,datablock[0..size-1])
      @data[key] = item
      client.puts "STORED"
    end

    #add newkey 0 60 5
    def add(client,key, flags, ttl, size, datablock)
      if @data[key]
        client.puts "NOT STORED"
      else 
        item = Item.new(key,flags,ttl,size,datablock[0..size-1])
        @data[key] = item
        client.puts "STORED"
      end
    end

    #replace key 0 60 5
    def replace(client,key, flags, ttl, size, datablock)
      if @data[key] 
        item = Item.new(key,flags,ttl,size,datablock[0..size-1])
        @data[key] = item
        client.puts "STORED"
      else
        client.puts "NOT STORED"
      end
    end

    #append key 0 60 15
    def append(client,key, flags, ttl, size, datablock)
      if @data[key] 
        item = @data[key]
        item.size = item.size + size
        item.expiration = ttl
        item.flags = flags
        item.value = item.value + datablock[0..size-1]
        @data[key] = item
        client.puts "STORED"
      else
        client.puts "NOT STORED"
      end
    end

    #prepend key 0 60 15
    def prepend(client, key, flags, ttl, size, datablock)
      if @data[key] 
        item = @data[key]
        item.size = item.size + size
        item.expiration = ttl
        item.flags = flags
        item.value = datablock[0..size-1] + item.value
        @data[key] = item
        client.puts "STORED"
      else
        client.puts "NOT STORED"
      end
    end

    #"cas" is a check and set operation which means "store this data but only if no one else has updated since I last fetched it."
    def cas(client, key, flags, ttl, size, cas, datablock)
      if @data[key] 
        item = @data[key]
        item.size = item.size + size
        item.expiration = ttl
        item.flags = flags
        item.cas = cas
        item.value = datablock[0..size-1] + item.value
        @data[key] = item
        client.puts "STORED"
      else
        client.puts "NOT STORED"
      end
    end
  end

  #servidor = Server.new()
  #servidor.connect()
  #servidor.get(["1","3","7"])
  #puts("=======================")
  #servidor.set("7","FF",0,5,"cebolla")
  #puts("=======================")
  #servidor.get("7")
  #puts("=======================")
  #servidor.add("7","FF",0,7,"cebolla")
  #puts("=======================")
  #servidor.get("7")
  #puts("=======================")
  #servidor.replace("7","FF",0,7,"cebolla")
  #puts("=======================")
  #servidor.get("7")
  #puts("=======================")
  #servidor.append("7","FF",0,5,"rodriguez")
  #puts("=======================")
  #servidor.get("7")
  #puts("=======================")
  #servidor.prepend("7","FF",0,8,"cristiant")
  #puts("=======================")
  #servidor.get("7")





  