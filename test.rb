#!/usr/bin/env ruby
require_relative "client.rb"
require_relative "server.rb"
require 'minitest/spec'
require 'minitest/autorun'
require "test/unit"
require "stringio"

class TestServer < MiniTest::Unit::TestCase

    def test_connect
        server = Server.new(2015)
        assert_output( /RUNNING SERVER/) {server.connect()}
    end

    def test_get
        server = Server.new(2010)
        server.connect()
        assert_output( /VALUE 1 0 0\nthiago\nEND/) {server.interprete(nil, "get 1")}
        server.interprete(nil, "gets 1")
    end

    def test_storage
        server = Server.new(2060)
        server.connect()
        server.interprete(nil, "set country 0 0 7 Uruguay")
        server.get(nil, ["country","city"])
        server.interprete(nil, "add country 0 0 7 Uruguay")
        server.get(nil, ["country","city"])
        server.interprete(nil, "add city 0 0 10 Montevideo")
        server.get(nil, ["country","city"])
        server.interprete(nil, "replace country 0 0 7 Bolivia")
        server.get(nil, ["country","city"])
        server.interprete(nil, "append city 0 0 7 Uruguay")
        server.get(nil, ["country","city"])
        server.interprete(nil, "prepend city 0 0 7 Pocitos")
        server.get(nil, ["country","city"])
    #    @server.interprete(nil, "cas country 0 0 7 Uruguay")
     #   @server.get(nil, ["country"])
    end


end

class TestClient < Test::Unit::TestCase

    def test_connect
       #client = Client.new()
      # assert_equal(client.connect(), puts('CONNECTED'))
    end

    def test_interprete
   #     client = Client.new()
    #    client.connect()
     #   assert_equal(client.interprete("get 1"), puts('VALUE 1 0 0'))
     end

end