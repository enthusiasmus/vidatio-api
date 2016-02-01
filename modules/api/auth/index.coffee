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
@api {get} user/ GET - login a user
@apiName login
@apiGroup Auth
@apiVersion 0.0.1
@apiDescription Login a user

@apiExample {curl} Example usage:
    curl http://localhost:3000/v0/auth -u admin:admin

@apiUse basicAuth
@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "message": "successfully authenticated"
        "user":
            "_id": 1231asdf2131
            "name": "user1"
            "email": "user1(at)vidatio.com"
    }
@apiErrorExample {json} Error-Response:
    HTTP/1.1 401 Unauthorized {}
@apiUse ErrorHandler
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
