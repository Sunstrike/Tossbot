# Redubot - Operators guide
All commands are in the form `~root subcommand parameters`

## Factoids module (FactoidsCore/FactoidsBackend)
Root command is ~factoid (or ~f) -- This for mods/ops only

- add/a/update/u - Adds or updates a factoid (e.g. `~f a Factoids There are factoids`)
- delete/d - Removes a factoid (e.g. `~f d Factoids`)

Anyone can call a factoid by `!factoidname`, where factoid name is the name of the chosen factoid. Another syntax, `!factoidname :name` is available to point `factoidname` at `person name`.

## LinkDetective module
The action taken by the bot will depend on the specific instances configuration; ask your bot administrator for more. It will either warn, timeout or ban on first and second offense, and may act more strongly on third strike.

Root command is ~permit (or ~p)

- Permit once: ~p once/o name
- Permit always: ~p always/a name
    - Caveat: Both permissions **expire** when the bot is restarted, as the states are held in memory. If this is an issue, please file a feature request for persistent storage of link allowances.
