"use strict"

{Router} = require "express"
passport = require "passport"

config   = require "../../config"
{_import:logger}   = require "../../logger"

http = require "http"

_import = Router()

basicAuth = passport.authenticate "basic",  session: false

adminAuth = (req, res, next) ->
    return res.status(401).end() unless req.user? and req.user.isAdmin?
    return res.status(401).end() if req.user.isAdmin is false
    logger.info { user: req.user }, "is admin"
    next()

importRoot = _import.route "/"

###
@api {get} import?url=:url GET - retrieve an external ressource via GET
@apiName importGet
@apiGroup Import
@apiVersion 0.0.1
@apiPermission admin
@apiDescription Forward an external ressource to our client.

@apiParam {String} url  external ressource.
@apiExample {curl} Example usage:
    curl -u admin:admin -i \
    http://localhost:3333/v0/import?url=http://www.wien.gv.at/statistik/ogd/b17-migrationbackground-vie-subdc.csv
###

importRoot.get ( req, res ) ->
    logger.debug url: req.query.url, "retrieve file from another server"

    request = http.get req.query.url, (resp) ->
        logger.debug code: resp.statusCode, "http code from http.get request"

        bodyChunks = []
        resp.on 'data', (chunk) ->
            bodyChunks.push chunk

        .on 'end', ->
            body = Buffer.concat bodyChunks
            logger.debug "return file"
            res.send body

    request.on 'error', (e) ->
        logger.error error:e.message, "wasn't able to retrieve file by url"
        res.status(500).json error: "not found"

module.exports =
    _import:   _import
