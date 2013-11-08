#!/usr/bin/env ruby -wKU

## Tossbot
##      => Global DB backend
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

class DBHandler

    @dbLink = nil
    @logger = nil

    def initialize(scrPath)
        @dbPath = "#{scrPath}/tossbot.db"
    end

    def setup(bot)
        if (@dbLink == nil)
            @logger = bot.loggers
            @logger.info "[DBHandler] Connecting to #{@dbPath}..."
            @dbLink = Sequel.connect(:adapter => 'sqlite', :database => @dbPath)
            @logger.info "[DBHandler] Connection established; ready for clients."
        end
    end

    def getSequel()
        @dbLink
    end

end
