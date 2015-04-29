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
               "Content-Type, Accept, Authorization, X-HTTP-Method-Override"
    res.header "Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS"

    if req.method is "OPTIONS"
        res.status( 200 ).end()
    else
        next()


applyMiddlewares = ( app ) ->
    app.use passport.initialize()

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
    app.use bodyParser.urlencoded( extended: true )

    # parse json
    app.use bodyParser.json()

    # add the api
    app.use api



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
