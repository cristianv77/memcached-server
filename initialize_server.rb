#!/usr/bin/env ruby
require "socket"
require_relative "server.rb"

servidor = Server.new()
servidor.connect()