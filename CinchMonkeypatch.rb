## Azbot-Mini
##      => Cinch TwitchTV monkeypatch
#
# Twitch self-hosted moderation for the masses
# 
# No copyright assigned for this file for following reasons:
#   - Direct duplication from Cinch::Target#msg
#   - No copyright hurdles wanted for this monkeypatch.
#
# All credit for the original goes to the Cinch Rb contributors
# at https://github.com/cinchrb/cinch
#

module Cinch
    class Target
        # PRIVMSG monkeypatch - Remove @bot.mask check
        # as suggested in https://github.com/cinchrb/cinch/issues/91
        def msg(text, notice = false)
            debug "MONKEYPATCH: Executing Twitch-fixed msg function."

            text = text.to_s
            split_start = @bot.config.message_split_start || ""
            split_end   = @bot.config.message_split_end   || ""
            command = notice ? "NOTICE" : "PRIVMSG"
    
            text.split(/\r\n|\r|\n/).each do |line|
            maxlength = 510 - (":" + " #{command} " + " :").size
            maxlength_without_end = maxlength - split_end.bytesize
    
            if line.bytesize > maxlength
                splitted = []
    
                while line.bytesize > maxlength_without_end
                    pos = line.rindex(/\s/, maxlength_without_end)
                    r = pos || maxlength_without_end
                    splitted << line.slice!(0, r) + split_end.tr(" ", "\u00A0")
                    line = split_start.tr(" ", "\u00A0") + line.lstrip
                end
    
                splitted << line
                splitted[0, (@bot.config.max_messages || splitted.size)].each do |string|
                    string.tr!("\u00A0", " ") # clean string from any non-breaking spaces
                    @bot.irc.send("#{command} #@name :#{string}")
              end
            else
                @bot.irc.send("#{command} #@name :#{line}")
            end
          end
        end
        alias_method :send, :msg
        alias_method :privmsg, :msg
    end
end