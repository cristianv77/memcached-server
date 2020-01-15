#!/usr/bin/env ruby
require "socket"
require_relative "server.rb"

class Client 

    attr_accessor :server
    attr_accessor :localdata
    attr_accessor :socket
  
    def initialize()
      @localdata = {}
    end
  
    def connect()
      hostname = 'localhost'
      port = 2000
      @socket = TCPSocket.open(hostname, port)
      #while 
      line = @socket.gets     # Read lines from the socket
      puts("CONNECTED") 
      puts(line.chop)       # And print with platform line terminator
      #end
    end

    def help()
      puts("COMMANDS:")
      puts("get:")
      puts("gets:")
      puts("set:")
      puts("add:")
      puts("replace:")
      puts("append:")
      puts("prepend:")
      puts("cas:")
    end
  
    def interprete()
      command =""
      while command != "-q" && command != "quit"
        line = gets.chomp
        array = line.split(" ")
        command = array[0]
        case command 
          when "telnet"
            connect()
          when "-h", "help"
            array.length === 1 ? help(): puts("Not help parameters")
          when "-q", "quit"
            puts("CLOSED")
          when "get","gets"
            array.length === 2 ? @socket.write(line): puts("Wrong parameters")
          when "set","add","replace","append","prepend"
            datablock = gets.chomp
            array.length === 5 ? @socket.write(line + " " + datablock): puts("Wrong parameters")
          when "cas"
            array.length === 5 ? @server.cas(array[1],array[2],Integer(array[3]),Integer(array[4]), datablock): puts("Wrong parameters")
          else 
            puts("Wrong command")
        end
      end
    end
end

 
int = Client.new()
int.interprete()
#int.interprete('gets 1,2')
#int.interprete('set 7 0 0 8 cristian')
#int.interprete('add 7 0 0 7 cebolla')
#int.interprete('replace 7 0 0 7 cebolla')
#int.interprete('append 7 0 0 8 rodriguez')
#int.interprete('prepend 7 0 0 8 cristian')
#int.interprete('get 7')
