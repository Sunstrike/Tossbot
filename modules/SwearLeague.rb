#!/usr/bin/env ruby -wKU

## Tossbot
##      => Swear League core
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

require_relative 'SwearLeagueBackend.rb'

class SwearLeagueCore
    include Cinch::Plugin

    @@swears = [
        {:word => " windows", :weight  => 1},
        {:word => " asp.net", :weight  => 1}
        {:word => " piss", :weight     => 1},
        {:word => "@slap", :weight     => 1},
        {:word => "bollocks", :weight  => 1},
        {:word => " tits", :weight     => 1},
        {:word => " slut", :weight     => 1},
        {:word => " wank", :weight     => 1},
        {:word => " dick", :weight     => 1},
        {:word => " bastard", :weight  => 1},
        {:word => " cock", :weight     => 1},
        {:word => " arse", :weight     => 1},
        {:word => " shit", :weight     => 2},
        {:word => " whore", :weight    => 2},
        {:word => " vista", :weight    => 6},
        {:word => " nigger", :weight   => 6},
        {:word => "fuck", :weight      => 10},
        {:word => "gregtech", :weight  => 10}
        {:word => " cunt", :weight     => 20}
    ]

    match /sw?e?a?r? .+/i, { :method => :control }
    match /.+/i, { :prefix => '', :method => :check }

    def initialize(bot)
        super(bot)
        @backend = SwearLeagueBackend.new(config[:db_handler], bot)
    end

    def check(msg)
        nick = msg.user.nick
        str = msg.message.downcase
        score = 0
        @@swears.each {|s|
            sc = str.scan(s[:word])
            if sc != nil
                score += sc.length * s[:weight]
            end
        }

        if score != 0
            currScore = @backend.getScore(nick)
            ret = @backend.addToScore(nick, score).amount
            if (currScore == 0)
                msg.reply "#{nick} just got a swearers loyalty card. (1+)"
            elsif (currScore < 100 && ret >= 100)
                msg.reply "#{nick} is very pottymouthed. (100+)"
            end
        end
    end

    def control(msg)
        debug "FCMSG (Command: #{msg.command}, Params: #{msg.params.inspect}, Message: #{msg.message}, Raw: #{msg.raw})"
        matches = /^~sw?e?a?r? (\w+) ?(\w+)? ?(.+)?$/i.match(msg.message)

        if matches[1] == nil then return end
        # Check for list call
        if /^(li?s?t?)$/i.match(matches[1]) != nil
            msg.reply("Swearers for instance: #{@backend.getStoredNicks}")
            return
        end

        # Check for stats call
        if /^(st?a?t?s?)$/i.match(matches[1]) != nil
            top = @backend.getHighScore
            if (top[:nick] != nil)
                msg.reply "#{top[:nick]} is the most pottymouthed here with a score of #{top[:score]}."
            end
        end

        if matches[1] == nil || matches[2] == nil then return end

        cmd = matches[1]
        fname = matches[2]

        if /^ge?t?$/i.match(cmd) != nil
            res = @backend.getScore(fname)
            if ((res == nil || res == 0) && msg.channel.has_user?(fname))
                msg.reply "#{fname} has been a good boy/girl (delete as appropriate) -- No record."
            elsif (res == nil || res == 0)
                msg.reply "I don't know of anyone by that nick..."
            else
                msg.reply "#{fname} currently is sitting on a score of #{res}."
            end
        end

        if adminPermCheck(msg.user, msg.channel)
            cmd.downcase!
            if /^(de?l?e?t?e?)$/i.match(cmd) != nil
                msg.reply(delete(fname))
            end
        end
    end

    def delete(nick)
        @backend.deleteNick(nick.downcase)
        "Nick '#{nick}' deleted."
    end

    def adminPermCheck(user, chan)
        chan.opped?(user) || chan.half_opped?(user) || chan.voiced?(user)
    end
end