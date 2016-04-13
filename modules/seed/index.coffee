"use strict"

module.exports =
    dev: (db) ->
        users = require("./users")(db, 5)
        categories = require("./category")(db)
        tags = require("./tags")(db)
        datasets = require("./datasets")(db, users, categories, tags, true)
    prod: (db) ->
        users = require("./users")(db, 1)
        categories = require("./category")(db)
        tags = require("./tags")(db)
        datasets = require("./datasets")(db, users, categories, tags, false)

