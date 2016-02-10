"use strict"

{Router} = require "express"
passport = require "passport"

{forward:logger}   = require "../../logger"

http = require "http"

forward = Router()

forwardRoot = forward.route "/"

###
@api {get} forward?url=:url GET - retrieve an external ressource via GET
@apiName forwardGet
@apiGroup Forward
@apiVersion 0.0.1
@apiDescription Forward an external ressource to our client.

@apiParam {String} url external ressource.
@apiExample {curl} Example usage:
    curl -u admin:admin -i \
    http://localhost:3000/v0/forward?url=http://data.ooe.gv.at/files/cms/Mediendateien/OGD/ogd_abtStat/Wahl_LT_09_OGD.csv
###

forwardRoot.get (req, res) ->
    logger.info "retrieve file from another server"
    logger.debug
        params: req.query.url

    request = http.get req.query.url, (resp) ->
        logger.debug
            code: resp.statusCode, "http code from http.get request"

        filePath = resp.headers['content-type']
        fileType = filePath.split "/"
        fileType = fileType[fileType.length - 1].toLowerCase()

        if fileType isnt "octet-stream" and fileType isnt "zip"
            logger.error error: "Data format not supported"
            logger.debug fileType: fileType
            res.status(500).json error: "Data format not supported"
            return

        chunks = []
        resp.on 'data', (chunk) ->
            chunks.push chunk
        .on 'end', ->
            body = Buffer.concat chunks

            # CSV (octet-stream) has to be send to the client as string
            if fileType is 'octet-stream'
                body = body.toString()
                fileType = 'csv'

            res.send
                fileType: fileType
                body: body

    request.on 'error', (e) ->
        logger.error error: e.message, "wasn't able to retrieve file by url"
        res.status(500).json error: "not found"

module.exports =
    forward: forward
