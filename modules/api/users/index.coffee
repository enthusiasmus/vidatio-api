"use strict"

{Router} = require "express"
passport = require "passport"
{BasicStrategy:BasicStrategy} = require "passport-http"

config   = require "../../config"
errorHandler   = require "../../helper/error-handler"

{user:logger}   = require "../../logger"

{model:User} = require "./user"
{model:Dataset} = require "../datasets/dataset"

user = Router()

basicAuth = passport.authenticate "basic",  session: false

userRoot = user.route "/"

###
@api {post} user/ POST - register a user
@apiName addUser
@apiGroup User
@apiVersion 0.0.1
@apiDescription Register a new User

@apiParam {String} email  Users' email
@apiParam {String} name  Users' name
@apiParam {String} password  Users' password

@apiExample {curl} Example usage:
    curl http://localhost:3000/v0/users -H "Content-Type: application/json" -d '{"email": "admin@admin.com", "name":"admin", "password": "admin"}'

@apiUse SuccessUser
@apiUse ErrorHandler
###

userRoot.post (req, res) ->
    logger.info "creating new user"
    logger.debug params: req.body

    user = new User

    user.email = req.body.email
    user.name = req.body.name
    user.password = req.body.password

    user.save (error, user) ->
        if error?
            logger.error error: error, "error registering user"
            error = errorHandler.format error
            return res.status(500).json error: error

        logger.debug user: user, "success registering user"

        return res.json
            _id: user._id
            name: user.name
            email: user.email

userCheckRoot = user.route "/check"

###
@api {check} user/check?email&name GET - check if a username or email exists
@apiName checkUser
@apiGroup User
@apiVersion 0.0.1

@apiDescription Check if the given username or email is already in the database.

@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "message": "user not found"
        "available": true
    }

@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "message": "user@admin.com not available"
        "available": false
    }
@apiErrorExample {status} Error-Response:
    HTTP/1.1 404 Not Found
    {
        error: "not found"
    }
###

userCheckRoot.get (req, res) ->
    logger.info "check if user with email or username already exists"
    logger.info params: req.query

    for key, value of req.query
        switch key
            when "email", "name"
                obj = "#{key}": value
                User.findOne obj, (error, user) ->
                    if error?
                        logger.error error: error, "wasn't able to find user by #{key}"
                        error = errorHandler.format error
                        return res.status(500).json error: error

                    if not user? or user.deleted
                        logger.error error: error, "wasn't able to find user by #{key}"
                        return res.status(200).json
                            message: "user not found"
                            available: true

                    logger.debug user: user, "found user by #{key}"
                    return res.status(200).json
                        message: value + " not available"
                        available: false
            else
                logger.error error: "wasn't able to handle key #{key}"
                return res.status(404).json error: "not found"


userDatasetsRoot = user.route "/:id/datasets"

###
@api {check} user/:id/datasets/ GET - get datasets by user id
@apiName getDatasets
@apiGroup User
@apiVersion 0.0.1

@apiDescription Get datasets by user id.

@apiExample {curl} Example usage:
    curl http://localhost:3000/v0/user/56376b6406e4eeb46ad32b5/datasets

@apiUse SuccessDatasets
@apiErrorExample {status} Error-Response:
    HTTP/1.1 500
    {
        error: "error retrieving datasets"
    }
###

userDatasetsRoot.get (req, res) ->
    logger.info "get datasets by user id"
    logger.debug params: req.params

    Dataset.find
        "userId": req.params.id
    .populate "userId", "name"
    .populate "metaData.category metaData.tags", "name -_id"
    .exec (error, datasets) ->
        if error?
            logger.error error: error, "error retrieving datasets"
            error = errorHandler.format error
            return res.status(500).json error: error
        else
            unless datasets?
                datasets = []

            logger.debug datasets: datasets, "return datasets"
            return res.status(200).json datasets


module.exports =
    user: user
