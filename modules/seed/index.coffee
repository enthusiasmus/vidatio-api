"use strict"

seedNumberUsers = 5
module.exports = (db) ->
    users = require("./users")(db, seedNumberUsers)
    categories = require("./category")(db)
    tags = require("./tags")(db)
    datasets = require("./datasets")(db, users, categories, tags)

