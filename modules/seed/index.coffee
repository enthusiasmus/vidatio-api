glob = require "glob"

class Seeder
    constructor: ->
        @matches = glob.sync "../api/users/seed.*", {cwd: __dirname}

    start: ->
        for value, i in @matches
            console.log "Found file #{value}"
            console.log process.cwd()
            require("#{value}")( (isFinished) ->
                console.log isFinished
            )

module.exports = new Seeder
