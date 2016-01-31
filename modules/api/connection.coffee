"use strict"

mongoose = require "mongoose"

seeder = require "../seed"
config = require "../config"

{api:logger} = require "../logger"

connection = ""

connect = ->
    connection = mongoose.createConnection config.mongo,
        server:
            socketOptions:
                keepAlive: 1

connect()

connection.on "error", (error) ->
    logger.error error: error , "error while creating db connection"
    setTimeout connect, 1000

connection.on "disconnected", ->
    logger.error "disconnected from server, trying to reconnect"
    connect()

connection.once "open", ->
    logger.info config.mongo, "db connection opened"
    seeder.start connection

module.exports = connection
