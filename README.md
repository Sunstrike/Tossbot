# Redubot
## Current features:
- Factoids
    - `~factoid update/set [name] [text]`
    - `~factoid delete [name]`
    - `![name]`
- Link detective
    - Adaptable alternative to Twitch link blocker
    - Auto allows moderators
    - `~permit once/always/strikes [name]`
        - once only allows one link, always allows all links **for this run** (not persistant), strikes resets the persons strike count.
