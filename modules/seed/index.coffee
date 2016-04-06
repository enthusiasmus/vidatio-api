"use strict"

seedNumberUsers = 5

module.exports =
    dev: (db) ->
        users = require("./users")(db, seedNumberUsers)
        categories = require("./category")(db)
        tags = require("./tags")(db)
        datasets = require("./datasets")(db, users, categories, tags, true)
    prod: (db) ->
        users = require("./users")(db, 1)
        categories = require("./category")(db)
        tags = require("./tags")(db)
        datasets = require("./datasets")(db, users, categories, tags, false)

