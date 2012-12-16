#!/usr/bin/env ruby -wKU

## Azbot-Mini
##      => Core
#
# Twitch self-hosted moderation for the masses
# 
# Copyright (C) 2012 Robert Tully
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
require_relative 'About.rb'
require_relative 'config.rb'

require_relative 'CinchMonkeypatch.rb' # Fix for Twitch+Cinch weirdness due to WHOIS

JTVIRC_SERVER = "#{STREAMER_NAME}.jtvirc.com"

if UTILITIES_ENABLED
    require_relative 'Utilities.rb'
    plugins = [About, Hugsim, Ecu, Bord, Sunstrike, Cubby, NES]
else
    plugins = [About]
end

if $IP_RESPONDER
    require_relative 'IP.rb'
    plugins << IP
end
if $MODS_RESPONDER
    require_relative 'Mods.rb'
    plugins << Mods
end
if $STREAMIP_RESPONDER
    require_relative 'StreamIP.rb'
    plugins << StreamIP
end
if $REDUX_RESPONDER
    require_relative 'Redux.rb'
    plugins << Redux
end

puts "STARTING CINCH CORE:"
puts "\tServer: #{JTVIRC_SERVER}"
puts "\tChannel: ##{STREAMER_NAME}"
puts "\tBot Account: #{$JTVIRC_ACCOUNT}"

bot = Cinch::Bot.new do
    configure do |c|
        c.server = JTVIRC_SERVER
        c.nick = $JTVIRC_ACCOUNT
        c.user = $JTVIRC_ACCOUNT
        c.password = JTVIRC_PASSWORD
        c.channels = ["##{STREAMER_NAME}"]
        c.plugins.plugins = plugins
        c.messages_per_second = 1
    end
end

if !DEBUG_MODE
    bot.start
end