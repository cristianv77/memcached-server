require "socket"


class Server
    attr_accessor :port
    attr_accessor :options
    attr_reader :sock
  
    def initialize(port)
      @port = port
      @sock = nil
      @options = {}
      @data = {"1" => "thiago", "2" => "tito", "3" => "topo"}
    end

    def connect()
        @pid = Process.pid
  #      server  = TCPServer.new("localhost", @port)
        @sock = KSocket::TCP.open("localhost", @port, self, "")
        addr = Socket.pack_sockaddr_in(@port, "localhost")
        sock = start(addr)
        #setsockopts(sock, options)
        #sock.options = options
        sock.server = self
        sock.kgio_wait_writable
        sock
       # loop {
      #      client  = server.accept
     #       request = client.readpartial(2048)
   #         puts request
  #      }
    end
  
    def get(keys)
      if keys.respond_to?("each")
        keys.each do |key|
          if @data[key]
            puts "VALUE #{key} #{@options[keys]}"
            puts "#{@data[key]}"
          end
        end
      else
        if @data[keys]
          puts "VALUE #{keys} #{@options[keys]}"
          puts "#{@data[keys]}"
        end
      end 
      puts "END"
    end

    def gets(keys)
    end
  
    #set mykey <flags> <ttl> <size>
    def set(key, flags, ttl, size, datablock)
      @options[key] = "#{flags} #{ttl} #{size}"
      @data[key] = "#{datablock[0..size-1]}"
      puts "STORED"
    end

    #add newkey 0 60 5
    def add(key, flags, ttl, size, datablock)
      if @data[key]
        puts "NOT STORED"
      else 
        @options[key] = "#{flags} #{ttl} #{size}"
        @data[key] = "#{datablock[0..size-1]}"
        puts "STORED"
      end
    end

    #replace key 0 60 5
    def replace(key, flags, ttl, size, datablock)
      if @data[key] 
        @options[key] = "#{flags} #{ttl} #{size}"
        @data[key] = "#{datablock[0..size-1]}"
        puts "STORED"
      else
        puts "NOT STORED"
      end
    end

    #append key 0 60 15
    def append(key, flags, ttl, size, datablock)
      if @data[key] 
        actualsize = @options[key].split(" ")[2]
        newsize = Integer(actualsize) + size
        @options[key] = "#{flags} #{ttl} #{newsize}"
        @data[key] = @data[key]+"#{datablock[0..size-1]}"
        puts "STORED"
      else
        puts "NOT STORED"
      end
    end

    #prepend key 0 60 15
    def prepend(key, flags, ttl, size, datablock)
      if @data[key] 
        actualsize = @options[key].split(" ")[2]
        newsize = Integer(actualsize) + size
        @options[key] = "#{flags} #{ttl} #{newsize}"
        @data[key] = "#{datablock[0..size-1]}"+@data[key]
        puts "STORED"
      else
        puts "NOT STORED"
      end
    end

    #"cas" is a check and set operation which means "store this data but only if no one else has updated since I last fetched it."
    def cas(key)
      puts(12)
    end
  end

  servidor = Server.new(12)
  servidor.get(["1","3","7"])
  puts("=======================")
  servidor.set("7","FF",0,5,"cebolla")
  puts("=======================")
  servidor.get("7")
  puts("=======================")
  servidor.add("7","FF",0,5,"cebolla")
  puts("=======================")
  servidor.get("7")
  puts("=======================")
  servidor.replace("7","FF",0,7,"cebolla")
  puts("=======================")
  servidor.get("7")
  puts("=======================")
  servidor.append("7","FF",0,5,"rodriguez")
  puts("=======================")
  servidor.get("7")
  puts("=======================")
  servidor.prepend("7","FF",0,8,"cristiant")
  puts("=======================")
  servidor.get("7")
  