"use strict"

{Router} = require "express"

errorHandler   = require "../../helper/error-handler"

{tag:logger}   = require "../../logger"

{model:Tag} = require "./tag"

tag = Router()

tagRoot = tag.route "/"

###
@api {get} tags/ GET - get all tags
@apiName getTags
@apiGroup Tags
@apiVersion 0.0.1
@apiDescription Get all available Tags

@apiExample {curl} Example usage:
    curl -i https://api.vidatio.com/v0/tags

@apiUse SuccessTags
@apiUse ErrorHandlerMongo
###

tagRoot.get (req, res) ->
    logger.info "get all tags"
    logger.debug params: req.body

    Tag.find {}
    .sort
        "name": 1
    .exec (error, tags) ->
        if error?
            logger.error error: error, "error retrieving tags"
            return res.status(500).json error: errorHandler.format error
        else
            unless tags?
                tags = []

            logger.debug tags: tags, "return tags"
            return res.status(200).json tags

module.exports =
    tag: tag
