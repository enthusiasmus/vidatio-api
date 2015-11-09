"use strict"

fs = require "fs"

bunyan   = require "bunyan"
{Router} = require "express"

config   = require "./config"

# create log dir if not exists
try
    stat = fs.statSync( config.dirs.log )
    throw new Error "error" unless stat.isDirectory()
catch e
    fs.mkdirSync config.dirs.log


# define all loggers here
loggers =
    penguins: bunyan.createLogger
        name: "penguins"
        streams: [
            type:   "rotating-file"
            path:   "#{ config.dirs.log }/penguins.log"
            period: "1d"
            count:  365
        ]
        level: "trace"
        serializers:
            bunyan.stdSerializers
    api: bunyan.createLogger
        name: "api"
        streams: [
            type:   "rotating-file"
            path:   "#{ config.dirs.log }/api.log"
            period: "1d"
            count:  365
        ]
        level: "trace"
        serializers:
            bunyan.stdSerializers
    _import: bunyan.createLogger
        name: "_import"
        streams: [
            type:   "rotating-file"
            path:   "#{ config.dirs.log }/upload.log"
            period: "1d"
            count:  365
        ]
        level: "trace"
        serializers:
            bunyan.stdSerializers
    user: bunyan.createLogger
        name: "user"
        streams: [
            type:   "rotating-file"
            path:   "#{ config.dirs.log }/users.log"
            period: "1d"
            count:  365
        ]
        level: "trace"
        serializers:
            bunyan.stdSerializers
    auth: bunyan.createLogger
        name: "auth"
        streams: [
            type:   "rotating-file"
            path:   "#{ config.dirs.log }/auth.log"
            period: "1d"
            count:  365
        ]
        level: "trace"
        serializers:
            bunyan.stdSerializers

module.exports.loggers = loggers

# export levels
levels =
    TRACE: bunyan.TRACE
    DEBUG: bunyan.DEBUG
    INFO:  bunyan.INFO
    WARN:  bunyan.WARN
    ERROR: bunyan.ERROR
    FATAL: bunyan.FATAL

module.exports.levels  = levels

# assign all loggers directly to the exports object
# attention: don't override existing keys
for key, logger of loggers
    module.exports[key] = logger

# same here ;)
for key, level of levels
    module.exports[key] = level

# get level of a specific logger
module.exports.getLevel = ( name ) ->
    return loggers[name].level() if loggers[name]
    return

# set level of a specific logger
module.exports.setLevel = ( name, level ) ->
    for key, logger of loggers
        logger.level( level ) if key is name or name is 0
    return


getLevelName = ( level ) ->
    for prop of levels
        if levels.hasOwnProperty prop
            return prop if levels[prop] is level

# get all streams of a specific logger
getLoggerStreams = ( logger ) ->
    result = []
    for stream in logger.streams
        result.push
            type:   stream.type
            path:   stream.path
            period: stream.period
            count:  stream.count
            level:  getLevelName stream.level
    result


removeCircularDeps = ( obj ) ->
    cache = []
    stripCircular = ( key, value ) ->
        if value? and typeof value is "object"
            return if cache.indexOf(value) isnt -1
            cache.push value
        value
    JSON.parse JSON.stringify obj, stripCircular


router = Router()

# returns all loggers
router.route("/").get ( req, res ) ->
    res.json( {
        name: key
        level: getLevelName logger.level()
        streams: getLoggerStreams logger
        } for key, logger of loggers )

# returns all levesl
router.route( "/levels" ).get ( req, res ) ->
    res.json levels

# returns a specific logger
router.route( "/:logger" ).get ( req, res ) ->
    if loggers[req.params.logger]
        res.json removeCircularDeps loggers[req.params.logger]
    else
        res.status(404).json error: "not found"

# set the level for a logger, it is a get request to make a change easier
# by typing it into the browser
router.route( "/:logger/:level" ).get ( req, res ) ->
    if loggers[req.params.logger]
        loggers[req.params.logger].level(req.params.level)
        res.json removeCircularDeps loggers[req.params.logger]
    else
        res.status(404).json error: "not found"

module.exports.routes = router
