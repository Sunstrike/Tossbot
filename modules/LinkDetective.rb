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
        @strikes = {}
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

        matches = /^~?pe?r?m?i?t? (on?c?e?|al?w?a?y?s?|st?r?i?k?e?s?) (\w+)$/.match(msg.message)
        if matches[1] == nil || matches[2] == nil
            return
        end

        debug "LD_PMSG: matches[1]: #{matches[1]}, matches[2]: #{matches[2]}, matches[1][0]: #{matches[1][0]}"

        if matches[1][0].downcase == 'o'
            # Once
            @allowedUsers[matches[2].downcase] = :once
            msg.reply "Allowing #{matches[2]} to link once."
        elsif matches[1][0].downcase == 'a'
            # Always
            @allowedUsers[matches[2].downcase] = :always
            msg.reply "Allowing #{matches[2]} to always link this run."
            @strikes[matches[2].downcase] = nil
        else
            # Strike reset
            msg.reply "Clearing strikes for #{matches[2]}."
            @strikes[matches[2].downcase] = nil
        end
    end

    def actOnUser(user, channel)
        if @strikes[user.name.downcase] == nil then @strikes[user.name.downcase] = 0 end
        @strikes[user.name.downcase] += 1

        if config[:strikes] && config[:strike_verbose]
            channel.msg "Do not post links to chat, #{user.name} - Strike #{@strikes[user.name.downcase]}"
        end

        if @strikes[user.name.downcase] >= 3 && config[:strikes]
            case config[:strike_action]
                when :timeout
                    channel.msg ".timeout #{user.name.downcase}"
                when :ban
                    channel.msg ".ban #{user.name.downcase}"
            end
            @strikes[user.name.downcase] = nil
        else
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
