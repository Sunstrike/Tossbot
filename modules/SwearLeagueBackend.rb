#!/usr/bin/env ruby -wKU

## Tossbot
##      => Swear League backend
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

require 'sequel'

RetTuple = Struct.new(:result, :amount)

class SwearLeagueBackend

    def initialize(handler, bot)
        @logger = bot.loggers
        @cache = {}
        @logger.info("[SwearLeagueBackend] Attaching to handler...")
        handler.setup(bot)
        @dbLink = handler.getSequel
        # Create table if needed
        @dbLink.create_table? :swearing do
            primary_key :id
            String :nick
            Int :score
        end
        @swearDb = @dbLink[:swearing]
        if @swearDb.empty?
            @logger.info('[SwearLeagueBackend] No entries in Swearing table! Quick, piss someone off!')
            @cache = {}
        else
            rebuildCache()
        end
    end

    def rebuildCache()
        @logger.info('[SwearLeagueBackend] Rebuilding memory-resident cache.')
        @cache = @swearDb.to_hash(:nick, :score)
    end

	def getScore(nick)
        nick.downcase!
        if @cache.has_key?(nick)
            return @cache[nick]
        else
            tmp = @swearDb.filter(:nick => nick).first
            if tmp == nil || tmp == 0
                return 0
            else
                # Self-repair in case of things in the DB but not in the cache
                rebuildCache()
                return tmp
            end
        end
    end

    def getHighScore()
        max = {:nick => nil, :score => 0}
        @cache.each {|k, v|
            if (v > max[:score])
                max[:nick] = k
                max[:score] = v
            end
        }

        max
    end

    def getStoredNicks()
        rebuildCache()
        out = ''
        @cache.each_key do |k|
            out += "#{k} "
        end
        out.chomp(' ')
    end

    def addToScore(nick, amnt)
        nick.downcase!
        tmp = @swearDb.filter(:nick => nick).first
        result = RetTuple.new
        result.result = :unknown
        result.amount = 0

        if tmp == nil || tmp == 0
            @swearDb.insert(:nick => nick, :score => amnt)
            @cache[nick] = amnt
            result.result = :add
            result.amount = amnt
        else
            newScore = getScore(nick) + amnt
            @swearDb.filter(:nick => nick).update(:score => newScore)
            @cache[nick] = newScore
            result.result = :update
            result.amount = newScore
        end

        result
    end

    def deleteNick(nick)
        nick.downcase!
        @swearDb.filter(:nick => nick).delete
        @cache.delete(nick)
    end
end
