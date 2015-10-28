"use strict"

{Router} = require "express"
passport = require "passport"
LocalStrategy = require('passport-local').Strategy

config   = require "../../config"
{user:logger}   = require "../../logger"


{model:User} = require "./user"

user = Router()

passport.use new LocalStrategy User.authenticate()
passport.serializeUser User.serializeUser()
passport.deserializeUser User.deserializeUser()

userRoot = user.route "/"


###
@api {post} user/ POST - register a user
@apiName addUser
@apiGroup User
@apiVersion 0.0.1
@apiDescription Register a new User-

@apiParam {String} email  Users' email
@apiParam {String} password  Users' password

@apiUse SuccessUser
###
userRoot.post (req, res) ->
    user = new User

    user.email = req.body.email

    User.register user, req.body.password, (err, user) ->
        console.log "hi"
        if err
            logger.debug err: err, "error registering user"
            res.status( 500 ).json error: err

        logger.info user: user, "success registering user"

        res.json
            _id: user._id
            email: user.email

        # passport auth still to do

module.exports =
    user: user
