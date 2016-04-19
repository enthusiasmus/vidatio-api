"use strict"

{Router} = require "express"
errorHandler   = require "../../helper/error-handler"
{category:logger}   = require "../../logger"
{model:Category} = require "./category"
category = Router()
categoryRoot = category.route "/"

###
@api {get} categories/ GET - Get all categories
@apiName getCategories
@apiGroup Categories
@apiVersion 0.0.1
@apiDescription Get all available Categories

@apiExample {curl} Example usage:
    curl -i https://api.vidatio.com/v0/categories

@apiUse SuccessCategory
@apiUse ErrorHandlerMongo
###

categoryRoot.get (req, res) ->
    logger.info "get all categories"
    logger.debug params: req.body

    Category.find {}
    .sort
        "name": 1
    .exec (error, categories) ->
        if error?
            logger.error error: error, "error retrieving categories"
            error = errorHandler.format error
            return res.status(500).json error: error
        else
            unless categories?
                categories = []

            logger.debug categories: categories, "return categories"
            return res.status(200).json categories

module.exports =
    category: category

