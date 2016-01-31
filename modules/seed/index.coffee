glob = require "glob"

class Seeder
    constructor: ->
        @matches = glob.sync "../api/**/seed.*", {cwd: __dirname}

    start: (db) ->
        for value, i in @matches
            console.log "Found seedfile #{value}"
            require("#{value}")(db)

module.exports = new Seeder
