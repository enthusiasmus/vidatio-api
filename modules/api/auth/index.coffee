"use strict"

{Router} = require "express"
passport = require "passport"
{BasicStrategy:BasicStrategy} = require "passport-http"

config   = require "../../config"
errorHandler   = require "../../helper/error-handler"

{auth:logger}   = require "../../logger"
{model:User} = require "../users/user"

auth = Router()

basicAuth = passport.authenticate "basic",  session: false

authRoot = auth.route "/"

###
@api {get} user/ GET - Authentication
@apiName authentication
@apiGroup Auth
@apiVersion 0.0.1
@apiDescription Authenticate a user

@apiExample {curl} Example usage:
    curl -i https://api.vidatio.com/v0/auth -u username:password

@apiUse basicAuth
@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "message": "successfully authenticated"
        "user":
            "_id": "4edd40c86762e0fb12000003"
            "name": "user1"
            "email": "user1@vidatio.com"
    }
@apiErrorExample {json} Error-Response:
    HTTP/1.1 401 Unauthorized {}
###

authRoot.get basicAuth, (req, res) ->
    logger.info "authenticate a user"
    res.status(200).json
        message: "successfully authenticated"
        user:
            _id: req.user._id
            name: req.user.name
            email: req.user.email

module.exports =
    auth: auth
