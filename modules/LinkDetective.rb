#!/usr/bin/env ruby -wKU

## Redubot
##      => Link moderation
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

class LinkDetective
    include Cinch::Plugin

    match /.+/i, { :prefix => '', :method => :check }
    match /pe?r?m?i?t? (.+)/i, { :method => :permit }

    def initialize(bot)
        super(bot)

        # From http://daringfireball.net/2010/07/improved_regex_for_matching_urls
        @webRegex = Regexp.compile('(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:\'".,<>?«»“”‘’]))', Regexp::EXTENDED | Regexp::IGNORECASE)
        @allowedUsers = {}
    end

    def check(msg)
        matches = @webRegex.match(msg.raw)
        if matches != nil
            if !hasPermission(msg.user, msg.channel)
                actOnUser(msg.user, msg.channel)
            end
        end
    end

    def permit(msg)
        if !adminPermCheck(msg.user, msg.channel)
            return
        end

        matches = /^~?pe?r?m?i?t? (on?c?e?|al?w?a?y?s?) (\w+)$/.match(msg.message)
        if matches[1] == nil || matches[2] == nil
            return
        end

        debug "LD_PMSG: matches[1]: #{matches[1]}, matches[2]: #{matches[2]}, matches[1][0]: #{matches[1][0]}"

        if matches[1][0] == 'o' || matches[1][0] == 'O'
            # Once
            @allowedUsers[matches[2].downcase] = :once
            msg.reply "Allowing #{matches[2].downcase} to link once."
        else
            # Always
            @allowedUsers[matches[2].downcase] = :always
            msg.reply "Allowing #{matches[2].downcase} to always link this run."
        end
    end

    def actOnUser(user, channel)
        case config[:action]
            when :delete
                sleep(1)
                channel.msg ".timeout #{user.name.downcase}"
                sleep(5)
                channel.msg ".unban #{user.name.downcase}"
            when :timeout
                channel.msg ".timeout #{user.name.downcase}"
            when :ban
                channel.msg ".ban #{user.name.downcase}"
        end
    end

    def hasPermission(user, channel)
        if @allowedUsers[user.name.downcase] != nil
            # Cull user from allow list if given one-time pass
            if @allowedUsers[user.name.downcase] == :once
                @allowedUsers[user.name.downcase] = nil
            end
            true
        else
            adminPermCheck(user, channel)
        end
    end

    def adminPermCheck(user, chan)
        chan.opped?(user) || chan.half_opped?(user) || chan.voiced?(user)
    end
end