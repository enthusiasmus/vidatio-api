"use strict"

{Router} = require "express"
passport = require "passport"

config   = require "../../config"
{upload:logger}   = require "../../logger"

http = require "http"

upload = Router()

basicAuth = passport.authenticate "basic",  session: false

adminAuth = (req, res, next) ->
    return res.status(401).end() unless req.user? and req.user.isAdmin?
    return res.status(401).end() if req.user.isAdmin is false
    logger.info { user: req.user }, "is admin"
    next()

uploadRoot = upload.route "/"

###
@api {get} upload?url=:url GET - retrieve an external ressource via GET
@apiName uploadGet
@apiGroup Upload
@apiVersion 0.0.1
@apiPermission admin
@apiDescription Forward an external ressource to our client.

@apiParam {String} url  external ressource.
@apiExample {curl} Example usage:
    curl -u admin:admin -i \
    http://localhost:3333/v0/upload?url=http://www.wien.gv.at/statistik/ogd/b17-migrationbackground-vie-subdc.csv
###

uploadRoot.get ( req, res ) ->
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
    upload:   upload
