"use strict"

seedNumberUsers = 5
module.exports = (db) ->
    users = require("./users")(db, seedNumberUsers)
    datasets = require("./datasets")(db, users)
    categories = require("./category")(db)
