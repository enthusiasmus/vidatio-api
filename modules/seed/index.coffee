"use strict"

seedNumberUsers = 5
module.exports = (db) ->
    users = require("./users")(db, seedNumberUsers)
    categories = require("./category")(db)
    datasets = require("./datasets")(db, users, categories)

