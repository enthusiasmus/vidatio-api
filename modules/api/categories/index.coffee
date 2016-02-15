"use strict"

{Router} = require "express"
passport = require "passport"
mongoose = require "mongoose"
{BasicStrategy:BasicStrategy} = require "passport-http"

config   = require "../../config"
errorHandler   = require "../../helper/error-handler"

{category:logger}   = require "../../logger"

{model:Category} = require "./category"

category = Router()

ObjectId = mongoose.Schema.Types.ObjectId

basicAuth = passport.authenticate "basic",  session: false

categoryRoot = category.route "/"

###
@api {get} categories/ GET - get all categories
@apiName getCategories
@apiGroup Categories
@apiVersion 0.0.1
@apiDescription Get all available Categories

@apiExample {curl} Example usage:
    curl http://localhost:3000/v0/categories

@apiUse SuccessCategories
@apiUse ErrorHandler
###

categoryRoot.get (req, res) ->
    logger.info "get all categories"
    logger.debug params: req.body

    Category.find {}, "-_id name", (error, categories) ->
        if error
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
