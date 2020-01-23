#!/usr/bin/env ruby
require "socket"
require_relative "item.rb"

class Server
    attr_accessor :port
    attr_accessor :data
    attr_accessor :server
    
    def initialize(port = 2000)
      country = Item.new("country",0,0,7,"Uruguay")
      city = Item.new("city",0,0,10,"Montevideo")
      name = Item.new("name",0,0,8,"Cristian")
      @port = port
      @data = {"country" => country, "city" => city, "name" => name}
    end

    #Interprete method reads the line received and call the corresponding method
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

    #Purge method for deleting expired keys
    def purge()
      time = Time.now
      @data.each do |key, item|
        if item.expiration < time
          @data.delete(key)
          puts "DELETE #{item.value}"
        end
      end
    end

    #Connect the server
    def connect()
      @pid = Process.pid
      @server = TCPServer.open(@port)    
      puts("RUNNING SERVER")
    end

    #Listen what the server receives
    def listen()
      loop {                           
        Thread.start(@server.accept) do |client|
          client.puts(Time.now.ctime)   
          while line = client.recv(200)
            purge()
            puts line
            interprete(client,line)
          end
        end
      }
    end

    #Print method for printing in the client and in the server the response
    def print (client, line)
      if client != nil 
        client.puts(line)
      end
      puts line
    end
  
    #Get method
    def get(client,keys)
      line = ""
      keys.each do |key|
        if @data[key]
          item = @data[key]
          line += "VALUE #{key} #{item.flags} #{item.size}\n"
          line += "#{item.value}\n"
        end
      end
      line += "END\n"
      print(client, line)
    end

    #Gets method
    def getcas(client,keys)
      line = ""
      keys.each do |key|
        if @data[key]
          item = @data[key]
          line += "VALUE #{key} #{item.flags} #{item.size} #{item.cas}\n"
          line += "#{item.value}\n"
        end
      end
      line += "END\n"
      print(client, line)
    end
  
    #Set method
    def set(client,key, flags, ttl, size, datablock)
      item = Item.new(key,flags,ttl,size,datablock[0..size-1])
      @data[key] = item
      print(client, "STORED")
    end

    #Add method
    def add(client,key, flags, ttl, size, datablock)
      if @data[key]
        print(client,  "NOT STORED")
      else 
        item = Item.new(key,flags,ttl,size,datablock[0..size-1])
        @data[key] = item
        print(client,  "STORED")
      end
    end

    #Replace method
    def replace(client,key, flags, ttl, size, datablock)
      if @data[key] 
        item = Item.new(key,flags,ttl,size,datablock[0..size-1])
        @data[key] = item
        print(client,  "STORED")
      else
        print(client,  "NOT STORED")
      end
    end

    #Append method
    def append(client,key, flags, ttl, size, datablock)
      if @data[key] 
        item = @data[key]
        item.size = item.size + size
        item.ttl = ttl
        item.flags = flags
        item.value = item.value + datablock[0..size-1]
        ttl === 0 ? item.expiration = Time.now + (60*60*24*365*10): item.expiration = Time.now + ttl
        @data[key] = item
        print(client,  "STORED")
      else
        print(client,  "NOT STORED")
      end
    end

    #Prepend method
    def prepend(client, key, flags, ttl, size, datablock)
      if @data[key] 
        item = @data[key]
        item.size = item.size + size
        item.ttl = ttl
        item.flags = flags
        item.value = datablock[0..size-1] + item.value
        ttl === 0 ? item.expiration = Time.now + (60*60*24*365*10): item.expiration = Time.now + ttl
        @data[key] = item
        print(client,  "STORED")
      else
        print(client,  "NOT STORED")
      end
    end

    #Cas method
    def cas(client, key, flags, ttl, size, cas, datablock)
      if @data[key] 
        item = @data[key]
        if item.cas === cas 
          item.size = size
          item.ttl = ttl
          item.flags = flags
          item.cas = cas + 1
          item.value = datablock[0..size-1]
          ttl === 0 ? item.expiration = Time.now + (60*60*24*365*10): item.expiration = Time.now + ttl
          @data[key] = item
          print(client, "STORED")
        else 
          print(client, "EXISTS")
        end
      else
        print(client, "NOT_FOUND")
      end
    end
  end