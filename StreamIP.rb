## Azbot-Mini
##      => Stream IP filtering
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

puts "Loaded module: Stream IP filtering"

class StreamIP
    include Cinch::Plugin

    match $STREAMIP_REGEX, {:use_prefix => false, :use_suffix => false}

    def execute(msg)
        if $STREAMIP_ACTION == :warn
            debug "Warning #{msg.user.nick} for saying streamer IP - bad boy/girl"
            msg.reply "#{msg.user.nick}: #{$STREAMIP_WARN_MESSAGE}"
        elsif $STREAMIP_ACTION == :timeout
            fatal ":timeout action not implemented!"
        elsif $STREAMIP_ACTION == :ban
            fatal ":ban action not implemented!"
        else
            fatal "Failed to act on STREAMIP event! Invalid action identifier in config."
        end
    end
end