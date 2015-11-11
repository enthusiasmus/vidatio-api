"use strict"

{Router} = require "express"
passport = require "passport"
{BasicStrategy:BasicStrategy} = require "passport-http"

config   = require "../../config"
errorHandler   = require "../../helper/error-handler"

{auth:logger}   = require "../../logger"

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
    }
@apiErrorExample {json} Error-Response:
    HTTP/1.1 401 Unauthorized {}
@apiUse ErrorHandler
###

authRoot.get basicAuth, (req, res) ->
    logger.debug "authenticate a user"
    res.status(200).json message: "successfully authenticated"

module.exports =
    auth: auth
