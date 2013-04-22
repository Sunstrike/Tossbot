#!/usr/bin/env ruby -wKU

## Redubot
##      => Factoid backend connector
#
# Twitch self-hosted moderation for the masses
# 
# Copyright (C) 2012 Sunstrike
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

class FactoidBackend
    def initialize(rootDir, bot)
        @logger = bot.loggers
        @cache = {}
        path = 'factoids.db'
        @logger.info("[FactoidBackend] Attaching to #{path}")
        @dbLink = Sequel.connect(:adapter => 'sqlite', :database => path)
        # Create table if needed
        @dbLink.create_table? :factoids do
            primary_key :id
            String :name
            String :text
        end
        @factDb = @dbLink[:factoids]
        if @factDb.empty?
            @logger.info('[FactoidBackend] No entries in Factoid table! Use ~f set to add factoids or alter the SQLite3 DB manually.')
        else
            rebuildCache()
        end
    end

    def rebuildCache()
        @logger.info('[FactoidBackend] Rebuilding memory-resident cache.')
        @cache = @factDb.to_hash(:name, :text)
    end

	def getFactoid(name)
        name.downcase!
        if @cache.has_key?(name)
            return @cache[name]
        else
            tmp = @factDb.filter(:name => name).first
            if tmp == nil || tmp == ''
                return nil
            else
                # Self-repair in case of things in the DB but not in the cache
                rebuildCache()
                return tmp
            end
        end
	end

    def setOrUpdateFactoid(name, text)
        name.downcase!
        tmp = @factDb.filter(:name => name).first
        result = :unknown
        if tmp == nil
            @factDb.insert(:name => name, :text => text)
            result = :add
        else
            @factDb.filter(:name => name).update(:text => text)
            result = :update
        end
        @cache[name] = text
        return result
    end

    def deleteFactoid(name)
        name.downcase!
        @factDb.filter(:name => name).delete
        @cache.delete(name)
    end
end