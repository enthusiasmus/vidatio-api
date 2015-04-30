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
@api {post} upload/ POST - retrieve an external ressource
@apiName upload
@apiGroup Upload
@apiVersion 0.0.1
@apiPermission admin
@apiDescription Forward an external ressource to our client.

@apiParam {String} url  external ressource.

@apiUse basicAuth
###

uploadRoot.post basicAuth, ( req, res ) ->
    logger.debug url: req.body.url, "retrieve file from another server"

    request = http.get req.body.url, (resp) ->
        logger.debug code: resp.statusCode, "http code from http.get request"

        bodyChunks = []
        resp.on 'data', (chunk) ->
            bodyChunks.push chunk

        .on 'end', ->
            body = Buffer.concat bodyChunks
            logger.debug body: body, "return file"
            res.send body

    request.on 'error', (e) ->
        logger.error error:e.message, "wasn't able to retrieve file by url"
        res.status(500).json error: "not found"

module.exports =
    upload:   upload
