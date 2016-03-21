"use strict"

{Router} = require "express"
passport = require "passport"

{forward:logger}   = require "../../logger"

request = require "request-promise"
iconvlite = require "iconv-lite"
charsetDetector = require "node-icu-charset-detector"

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
    curl http://localhost:3000/v0/forward?url=http://data.ooe.gv.at/files/cms/Mediendateien/OGD/ogd_abtStat/Wahl_LT_09_OGD.csv
###

forwardRoot.get (req, res) ->
    logger.info "Retrieve file from another server"
    logger.debug
        params: req.query.url

    request
        "url": decodeURIComponent req.query.url
        "encoding": null
        "resolveWithFullResponse": true
    .then (resp) ->
        logger.debug
            code: resp.statusCode
        , "http code from http.get request"

        contentType = resp.headers["content-type"]
        logger.debug contentType: contentType, "header[content-type] of request url"

        body = resp.body
        # Headers are used from here https://www.iana.org/assignments/media-types/media-types.xhtml
        switch contentType
            when "application/octet-stream", "text/csv"
                #charset.toString, charset.language, charset.confidence
                charset = charsetDetector.detectCharset new Buffer(body.toString("binary"), "binary")
                body = iconvlite.decode body, charset.toString()
                logger.debug charset: charset, "encoding prediction"
                fileType = "csv"
            when "application/zip"
                fileType = "zip"
            else
                logger.error contentType: contentType, "Header cannot be used"
                return res.status(500).json error: "Data format not supported"

        return res.status(200).json
            fileType: fileType
            body: body

    .catch (error) ->
        logger.error error: error, "Wasn't able to retrieve or parse file"
        return res.status(500).json error: "An error occured"

module.exports =
    forward: forward
