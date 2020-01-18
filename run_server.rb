#!/usr/bin/env ruby
require "socket"
require_relative "server.rb"

server = Server.new()
server.connect()
server.listen()