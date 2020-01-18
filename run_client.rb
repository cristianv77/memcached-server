#!/usr/bin/env ruby
require "socket"
require_relative "client.rb"

client = Client.new()
client.read_command()