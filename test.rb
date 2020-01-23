#!/usr/bin/env ruby
require_relative "client.rb"
require_relative "server.rb"
require 'minitest/spec'
require 'minitest/autorun'
require "test/unit"
require "stringio"

class TestServer < MiniTest::Unit::TestCase

    #Tests the server connection
    def test_connect
        server = Server.new(2010)
        assert_output( /RUNNING SERVER/) {server.connect()}
    end

    #Tests the get method
    def test_get
        server = Server.new(2011)
        server.connect()
        assert_output( /VALUE country 0 7\nUruguay\nEND/) {server.interprete(nil, "get country")}
        assert_output( /VALUE country 0 7\nUruguay\nVALUE city 0 10\nMontevideo\nEND/) {server.interprete(nil, "get country,city")}
        assert_output( /END/) {server.interprete(nil, "get lastname")}
    end

    #Tests the gets method
    def test_gets
        server = Server.new(2012)
        server.connect()
        assert_output( /VALUE country 0 7 1\nUruguay\nEND/) {server.interprete(nil, "gets country")}
        assert_output( /VALUE country 0 7 1\nUruguay\nVALUE city 0 10 1\nMontevideo\nEND/) {server.interprete(nil, "gets country,city")}
        assert_output( /END/) {server.interprete(nil, "gets lastname")}
    end

    #Tests the set method
    def test_set 
        server = Server.new(2013)
        server.connect()
        assert_output(/STORED/) {server.interprete(nil, "set country 0 0 7 Bolivia")}
        assert_output( /VALUE country 0 7\nBolivia\nEND/) {server.interprete(nil, "get country")}
        assert_output(/STORED/) {server.interprete(nil, "set lastname 0 0 6 Vargas")}
        assert_output( /VALUE lastname 0 6\nVargas\nEND/) {server.interprete(nil, "get lastname")}
    end

    #Tests the add method
    def test_add 
        server = Server.new(2014)
        server.connect()
        assert_output(/NOT STORED/) {server.interprete(nil, "add country 0 0 7 Bolivia")}
        assert_output( /VALUE country 0 7\nUruguay\nEND/) {server.interprete(nil, "get country")}
        assert_output(/STORED/) {server.interprete(nil, "add lastname 0 0 6 Vargas")}
        assert_output( /VALUE lastname 0 6\nVargas\nEND/) {server.interprete(nil, "get lastname")}
    end

    #Tests the replace method
    def test_replace 
        server = Server.new(2015)
        server.connect()
        assert_output(/STORED/) {server.interprete(nil, "replace country 0 0 7 Bolivia")}
        assert_output( /VALUE country 0 7\nBolivia\nEND/) {server.interprete(nil, "get country")}
        assert_output(/NOT STORED/) {server.interprete(nil, "replace lastname 0 0 6 Vargas")}
        assert_output( /END/) {server.interprete(nil, "get lastname")}
    end

    #Tests the append method
    def test_append 
        server = Server.new(2016)
        server.connect()
        assert_output(/STORED/) {server.interprete(nil, "append name 0 0 7 ,Vargas")}
        assert_output( /VALUE name 0 15\nCristian,Vargas\nEND/) {server.interprete(nil, "get name")}
        assert_output(/NOT STORED/) {server.interprete(nil, "append lastname 0 0 6 Vargas")}
        assert_output( /END/) {server.interprete(nil, "get lastname")}
    end

    #Tests the pretend method
    def test_prepend 
        server = Server.new(2017)
        server.connect()
        assert_output(/STORED/) {server.interprete(nil, "prepend city 0 0 8 Pocitos,")}
        assert_output( /VALUE city 0 18\nPocitos,Montevideo\nEND/) {server.interprete(nil, "get city")}
        assert_output(/NOT STORED/) {server.interprete(nil, "prepend lastname 0 0 6 Vargas")}
        assert_output( /END/) {server.interprete(nil, "get lastname")}
    end

    #Tests the cas method
    def test_cas 
        server = Server.new(2018)
        server.connect()
        assert_output(/NOT_FOUND/) {server.interprete(nil, "cas lastname 0 0 6 2 Vargas")}
        assert_output(/STORED/) {server.interprete(nil, "set lastname 0 0 6 Vargas")}
        assert_output( /VALUE lastname 0 6 1\nVargas\nEND/) {server.interprete(nil, "gets lastname")}
        assert_output(/EXISTS/) {server.interprete(nil, "cas lastname 0 0 5 2 Gomez")}
        assert_output(/STORED/) {server.interprete(nil, "cas lastname 0 0 5 1 Gomez")}
        assert_output( /VALUE lastname 0 5 2\nGomez\nEND/) {server.interprete(nil, "gets lastname")}
    end

end

class TestClient < MiniTest::Unit::TestCase

    #Tests the client connection
    def test_connect
       client = Client.new()
       assert_output( /CONNECTED/) {client.connect()}
    end

    #Tests the errors throwed by the client
    def test_errors
        client = Client.new()
        client.connect()
        assert_output( /ERROR\n For more than one key, keys must be separated by a comma, with no spaces. E.g. get key1,key2/) {client.interprete("get 1, 2")}
        assert_output( /ERROR/) {client.interprete("set country 0 0 5 5")}
        assert_output( /ERROR/) {client.interprete("cas country 0 0 5 5 3")}
        assert_output( /Key must not include a comma/) {client.interprete("cas country,city 0 0 5 5")}
        assert_output( /Flag parameter must be a number/) {client.interprete("cas country a 0 5 5")}
        assert_output( /Cas parameter must be a number/) {client.interprete("cas country 0 0 5 a")}
        assert_output( /TTL parameter must be a number/) {client.interprete("cas country 0 a 5 5")}
        assert_output( /Size must be a number/) {client.interprete("cas country 0 0 a 3")}
     end

end