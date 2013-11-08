# Tossbot - Operators guide
All commands are in the form `~root subcommand parameters`

## Factoids module (FactoidsCore/FactoidsBackend)
Root command is ~factoid (or ~f) -- This for mods/ops only

- add/a/set/s/update/u - Adds or updates a factoid (e.g. `~f a Factoids There are factoids`)
- delete/d - Removes a factoid (e.g. `~f d Factoids`)
- list/l - Lists all factoids on the current instance (`~f l`)

Anyone can call a factoid by `!factoidname`, where factoid name is the name of the chosen factoid. Another syntax, `!factoidname :name` is available to point `factoidname` at `person name`.

## Swear League module (SwearLeagueCore/SwearLeagueBackend)
Root command is ~swear (or ~s)

- delete/d - Removes a nick from the database (e.g. `~s d Sunstrike`) **+o/+v only**
- list/l - Lists all nicks stored on the current instance (`~s l`)
- stats/s - Gets the current top scoring nick (`~s s`)
- get/g - Gets score for a nick (`~s g Sunstrike`)
