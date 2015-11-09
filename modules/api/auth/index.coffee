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
###

authRoot.get basicAuth, (req, res) ->
    logger.debug "authenticate a user"
    res.status(200).json message: "successfully authenticated"

module.exports =
    auth: auth
