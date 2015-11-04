"use strict"

{Router} = require "express"
passport = require "passport"

{_import:logger}   = require "../../logger"

http = require "http"

_import = Router()

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
    http://localhost:3333/v0/import?url=http://data.ooe.gv.at/files/cms/Mediendateien/OGD/ogd_abtStat/Wahl_LT_09_OGD.csv
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
