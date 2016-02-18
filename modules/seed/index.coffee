"use strict"

# class Seeder
#     constructor: ->
#         @matches = glob.sync "../api/**/seed.*", {cwd: __dirname}

#     start: (db) ->
#         for value, i in @matches
#             console.log "Found seedfile #{value}"
#             require("#{value}")(db)

# module.exports = new Seeder

seedNumberUsers = 5
module.exports = (db) ->
    users = require("./users")(db, seedNumberUsers)
    datasets = require("./datasets")(db, users)
