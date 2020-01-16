#!/usr/bin/env ruby
require "socket"
require_relative "server.rb"

class Client 

    attr_accessor :server
    attr_accessor :localdata
    attr_accessor :connected
    attr_accessor :socket
  
    def initialize()
      @localdata = {}
      @connected = false
    end
  
    def connect()
      hostname = 'localhost'
      port = 2000
      @socket = TCPSocket.open(hostname, port)
      @connected = true
      line = @socket.gets   
      puts("CONNECTED") 
      puts(line.chop)
    end

    def send(line)
      @socket.write(line)
      response = @socket.recv(200) 
      puts(response.chop)      
    end

    def help()
      puts("COMMANDS:")
      puts("get: get <key>")
      puts("gets: gets <key>")
      puts("set: set <flag> <ttl> <size>")
      puts("add: add <flag> <ttl> <size>")
      puts("replace: replace <flag> <ttl> <size>")
      puts("append: append <flag> <ttl> <size>")
      puts("prepend: prepend <flag> <ttl> <size>")
      puts("cas:")
    end
  
    def interprete(line)
      array = line.split(" ")
      command = array[0]
      case command
        when "get","gets"
          array.length === 2 ? send(line): puts("Wrong parameters")
        when "set","add","replace","append","prepend"
          datablock = gets.chomp
          array.length === 5 ? send(line + " " + datablock): puts("Wrong parameters")
        when "cas"
          array.length === 6 ? send(line): puts("Wrong parameters")
          
      end
      
    end

    def read_command()
      command = ""
      while command != "-q" && command != "quit"
        line = gets.chomp
        array = line.split(" ")
        command = array[0]
        case command 
          when "telnet"
            @connected ? puts("ALREADY CONNECTED"): connect()
          when "-h", "help"
            array.length === 1 ? help(): puts("Not help parameters")
          when "-q", "quit"
            puts("CLOSED")
          when "get","gets", "set","add","replace","append","prepend","cas"
            @connected ? interprete(line): puts("Not connection with any server")
          else 
            puts("Wrong command")
        end
      end
    end
end

 
int = Client.new()
int.read_command()
#int.interprete('gets 1,2')
#int.interprete('set 7 0 0 8 cristian')
#int.interprete('add 7 0 0 7 cebolla')
#int.interprete('replace 7 0 0 7 cebolla')
#int.interprete('append 7 0 0 8 rodriguez')
#int.interprete('prepend 7 0 0 8 cristian')
#int.interprete('get 7')
