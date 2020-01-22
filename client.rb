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
  
    #Connect the socket to the server
    def connect(port = 2000)
      hostname = 'localhost'
      @socket = TCPSocket.open(hostname, port)
      @connected = true
      line = @socket.gets   
      puts("CONNECTED") 
      puts(line.chop)
    end

    #Send the command to the server and read response
    def send(line)
      @socket.write(line)
      response = @socket.recvfrom(2048)
      puts(response[0]) 
    end

    #Help method for printing in console
    def help()
      puts("COMMANDS:")
      puts("get: get <key>")
      puts("gets: gets <key>")
      puts("set: set <flag> <ttl> <size>")
      puts("      <datablock>")
      puts("add: add <flag> <ttl> <size>")
      puts("      <datablock>")
      puts("replace: replace <flag> <ttl> <size>")
      puts("      <datablock>")
      puts("append: append <flag> <ttl> <size>")
      puts("      <datablock>")
      puts("prepend: prepend <flag> <ttl> <size>")
      puts("      <datablock>")
      puts("cas: cas <flag> <ttl> <size> <cas>")
      puts("      <datablock>")
      puts("telnet: for connecting to the server")
    end

    #Help method for considering if a parameter received is a number of not
    def is_number? (string)
      true if Integer(string) rescue false
    end

    #Verify if parameters are numbers and if the key does not include a comma
    def verifyParameters(key, ttl, size, cas)
      ttlIsNumber = is_number?(ttl)
      sizeIsNumber = is_number?(size)
      casIsNumber = is_number?(cas)
      if key.include? ","
        puts("Key can not include a comma")
        return false 
      end 
      if !casIsNumber
        puts("Cas parameter must be a number")
        return false
      end 
      if !ttlIsNumber
        puts("TTL parameter must be a number")
        return false
      end
      if !sizeIsNumber
        puts("Size must be a number")
        return false
      end
      return true
    end 

    #Interprete the command writen, and verify parameters before sending
    def interprete(line)
      array = line.split(" ")
      command = array[0]
      key = array[1]
      case command
        when "get","gets"
          array.length === 2 ? send(line): puts("Wrong parameters")
        when "set","add","replace","append","prepend" 
          clean = verifyParameters(array[1],array[3], array[4],0)
          array.length === 5 ? (clean ? send(line + " " + gets.chomp): puts("For more information run help or -h.") ): puts("Wrong parameters") 
        when "cas"
          clean = verifyParameters(array[1],array[3], array[4],array[5])
          array.length === 6 ? (clean ? send(line + " " + gets.chomp ): puts("For more information run help or -h.") ): puts("Wrong parameters")
      end
    end

    #Read commands
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