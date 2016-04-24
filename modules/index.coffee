"use strict"

http       = require "http"

express    = require "express"
passport   = require "passport"
bodyParser = require "body-parser"
logger     = require "express-bunyan-logger"

# this config can be overridden, see module.exports
config = require "./config"

api = require "./api"

# self-explanatory
allowCors = ( req, res, next ) ->
    res.header "Access-Control-Allow-Origin", "*"
    res.header "Access-Control-Allow-Headers", "Origin, X-Requested-With, " +
               "Content-Type, Accept, Authorization, X-HTTP-Method-Override, Range-Unit, Range"
    res.header "Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS"
    res.header "Access-Control-Expose-Headers", "Content-Range"

    if req.method is "OPTIONS"
        res.status( 200 ).end()
    else
        next()


applyMiddlewares = ( app ) ->
    app.use passport.initialize()
    app.use passport.session()

    # add the logger middleware
    app.use logger
        name: "express"
        streams: [
            type:   "rotating-file"
            path:   "#{config.dirs.log}/access.log"
            period: "1d"
            count:  365
        ]

    # send CORS headers
    app.use allowCors

    # parse urlencode body, --> req.body
    app.use bodyParser.urlencoded({limit: '50mb', extended: true})

    # parse json
    app.use bodyParser.json({limit: '50mb'})

    # add the api
    app.use "/#{config.apiVersion}/", api

    app.use "*", (req, res) ->
        res.status(404).json error: "not found"

module.exports = ( newConfig ) ->
    # override config
    if newConfig?
        config[key] = val for key, val of newConfig

    # create the express instance
    app = express()

    # apply middlewares
    applyMiddlewares app

    # start it up, and return the server instance
    http.createServer( app ).listen config.port, ->
        console.log "Listening on #{ @address().address }:" +
                    "#{ @address().port }"
