#!/usr/bin/env ruby -wKU

## Azbot-Mini
##      => Factoid core
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

require_relative 'FactoidBackend.rb'

class FactoidCore
    include Cinch::Plugin

    match /fa?c?t?o?i?d? (.+)/i, { :method => :control }
    match /.+/i, { :prefix => "!", :method => :factoid }

    def initialize(bot)
        super(bot)
        @backend = FactoidBackend.new(config[:path], bot)
    end

    def factoid(msg)
        debug "FMSG (Command: #{msg.command}, Params: #{msg.params.inspect}, Message: #{msg.message}, Raw: #{msg.raw})"
    end

    def control(msg)
    	debug "FCMSG (Command: #{msg.command}, Params: #{msg.params.inspect}, Message: #{msg.message}, Raw: #{msg.raw})"
    end
end