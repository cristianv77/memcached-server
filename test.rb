#!/usr/bin/env ruby
require_relative "client.rb"
require_relative "server.rb"
require 'minitest/spec'
require 'minitest/autorun'
require "test/unit"
require "stringio"

class Testserver < MiniTest::Unit::TestCase

    #Tests the server connection
    $testServer = Server.new(2010)
    def test_connect
        assert_output( /RUNNING SERVER/) {$testServer.connect()}
    end

    #Tests the set method
    def test_set 
        assert_output(/STORED/) {$testServer.interprete(nil, "set country 0 0 7 Bolivia")}
        assert_output( /VALUE country 0 7\nBolivia\nEND/) {$testServer.interprete(nil, "get country")}
    end

    #Tests the get method
    def test_get_ok
        assert_output(/STORED/) {$testServer.interprete(nil, "set country 0 0 7 Bolivia")}
        assert_output( /VALUE country 0 7\nBolivia\nEND/) {$testServer.interprete(nil, "get country")}
    end
    def test_get_multiple_ok
        assert_output(/STORED/) {$testServer.interprete(nil, "set country 0 0 7 Bolivia")}
        assert_output(/STORED/) {$testServer.interprete(nil, "set city 0 0 10 Montevideo")}
        assert_output( /VALUE country 0 7\nBolivia\nVALUE city 0 10\nMontevideo\nEND/) {$testServer.interprete(nil, "get country,city")}
    end
    def test_get_not_key
        assert_output( /END/) {$testServer.interprete(nil, "get planet")}
    end

    #Tests the gets method
    def test_gets_ok
        assert_output(/STORED/) {$testServer.interprete(nil, "set country 0 0 7 Bolivia")}
        assert_output( /VALUE country 0 7 1\nBolivia\nEND/) {$testServer.interprete(nil, "gets country")}
    end
    def test_gets_multiple_ok
        assert_output(/STORED/) {$testServer.interprete(nil, "set country 0 0 7 Bolivia")}
        assert_output(/STORED/) {$testServer.interprete(nil, "set city 0 0 10 Montevideo")}
        assert_output( /VALUE country 0 7 1\nBolivia\nVALUE city 0 10 1\nMontevideo\nEND/) {$testServer.interprete(nil, "gets country,city")}
    end
    def test_gets_not_key
        assert_output( /END/) {$testServer.interprete(nil, "gets planet")}
    end

    #Tests the add method
    def test_add_not_stored
        assert_output(/STORED/) {$testServer.interprete(nil, "set country 0 0 7 Bolivia")}
        assert_output(/NOT STORED/) {$testServer.interprete(nil, "add country 0 0 7 Uruguay")}
        assert_output( /VALUE country 0 7\nBolivia\nEND/) {$testServer.interprete(nil, "get country")}
    end
    def test_add_stored
        assert_output(/STORED/) {$testServer.interprete(nil, "add lastname 0 0 6 Vargas")}
        assert_output( /VALUE lastname 0 6\nVargas\nEND/) {$testServer.interprete(nil, "get lastname")}
    end

    #Tests the replace method
    def test_replace_stored
        assert_output(/STORED/) {$testServer.interprete(nil, "set team 0 0 4 Boca")}
        assert_output(/STORED/) {$testServer.interprete(nil, "replace team 0 0 6 Racing")}
        assert_output( /VALUE team 0 6\nRacing\nEND/) {$testServer.interprete(nil, "get team")}
    end
    def test_replace_not_stored
        assert_output(/NOT STORED/) {$testServer.interprete(nil, "replace day 0 0 6 Monday")}
        assert_output( /END/) {$testServer.interprete(nil, "get day")}
    end

    #Tests the append method
    def test_append_stored
        assert_output(/STORED/) {$testServer.interprete(nil, "set name 0 0 8 Cristian")}
        assert_output(/STORED/) {$testServer.interprete(nil, "append name 0 0 7 ,Vargas")}
        assert_output( /VALUE name 0 15\nCristian,Vargas\nEND/) {$testServer.interprete(nil, "get name")}
    end
    def test_append_not_stored
        assert_output(/NOT STORED/) {$testServer.interprete(nil, "append planet 0 0 6 Earth")}
        assert_output( /END/) {$testServer.interprete(nil, "get planet")}
    end

    #Tests the pretend method
    def test_prepend_stored
        assert_output(/STORED/) {$testServer.interprete(nil, "set fullname 0 0 6 Vargas")}
        assert_output(/STORED/) {$testServer.interprete(nil, "prepend fullname 0 0 9 Cristian,")}
        assert_output( /VALUE fullname 0 15\nCristian,Vargas\nEND/) {$testServer.interprete(nil, "get fullname")}
    end
    def test_prepend_not_stored
        assert_output(/NOT STORED/) {$testServer.interprete(nil, "prepend brand 0 0 6 Nike")}
        assert_output( /END/) {$testServer.interprete(nil, "get brand")}
    end

    #Tests the cas method
    def test_cas_not_found
        assert_output(/NOT_FOUND/) {$testServer.interprete(nil, "cas brand 0 0 6 2 Adidas")}
    end
    def test_cas_exists
        assert_output(/STORED/) {$testServer.interprete(nil, "set surname 0 0 6 Vargas")}
        assert_output( /VALUE surname 0 6 1\nVargas\nEND/) {$testServer.interprete(nil, "gets surname")}
        assert_output(/EXISTS/) {$testServer.interprete(nil, "cas surname 0 0 5 2 Gomez")}
    end
    def test_cas_stored
        assert_output(/STORED/) {$testServer.interprete(nil, "set surname 0 0 6 Vargas")}
        assert_output( /VALUE surname 0 6 1\nVargas\nEND/) {$testServer.interprete(nil, "gets surname")}
        assert_output(/STORED/) {$testServer.interprete(nil, "cas surname 0 0 5 1 Gomez")}
        assert_output( /VALUE surname 0 5 2\nGomez\nEND/) {$testServer.interprete(nil, "gets surname")}
    end

end

class TestClient < MiniTest::Unit::TestCase

    #Tests the client connection
    $testClient =  Client.new()
    def test_connect
       assert_output( /CONNECTED/) {$testClient.connect()}
    end

    #Tests the errors throwed by the client
    def test_errors
        assert_output( /ERROR\n For more than one key, keys must be separated by a comma, with no spaces. E.g. get key1,key2/) {$testClient.interprete("get 1, 2")}
        assert_output( /ERROR/) {$testClient.interprete("set country 0 0 5 5")}
        assert_output( /ERROR/) {$testClient.interprete("cas country 0 0 5 5 3")}
        assert_output( /Key must not include a comma/) {$testClient.interprete("cas country,city 0 0 5 5")}
        assert_output( /Flag parameter must be a number/) {$testClient.interprete("cas country a 0 5 5")}
        assert_output( /Cas parameter must be a number/) {$testClient.interprete("cas country 0 0 5 a")}
        assert_output( /TTL parameter must be a number/) {$testClient.interprete("cas country 0 a 5 5")}
        assert_output( /Size must be a number/) {$testClient.interprete("cas country 0 0 a 3")}
     end

end