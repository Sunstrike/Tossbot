#!/usr/bin/env ruby -wKU

## Tossbot
##      => Core
#
# Copyright (C) 2013 Sunstrike
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#

require 'cinch'
require_relative 'modules/DBHandler.rb'
require_relative 'config.rb'

PATH = File.dirname(__FILE__)

plugins = []

if FACTOIDS
    require_relative 'modules/FactoidCore.rb'
    plugins << FactoidCore
end

if SWEARING
    require_relative 'modules/SwearLeague.rb'
    plugins << SwearLeagueCore
end

db_handler = DBHandler.new(PATH)

puts 'STARTING CINCH CORE:'
puts "\tServer: #{SERVER}"
puts "\tChannels: #{CHANNELS}"
puts "\tBot Account: #{ACCOUNT}"
puts "\tPatches: None."

bot = Cinch::Bot.new do
    configure do |c|
        c.server = SERVER
        c.nick = ACCOUNT
        c.user = ACCOUNT
        c.password = PASSWORD
        c.timeouts.connect = 30
        c.channels = CHANNELS
        c.messages_per_second = 1
        c.plugins[:prefix] = /^~/
        c.plugins.plugins = plugins

        if FACTOIDS
            c.plugins.options[FactoidCore] = { :db_handler => db_handler }
        end

        if SWEARING
            c.plugins.options[SwearLeagueCore] = { :db_handler => db_handler }
        end
    end
end

if !DEBUG_MODE
    bot.start
end
