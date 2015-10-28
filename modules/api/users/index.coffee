"use strict"

{Router} = require "express"
passport = require "passport"
LocalStrategy = require('passport-local').Strategy

config   = require "../../config"
{users:logger}   = require "../../logger"


{model:User} = require "./user"


# user = Router()
# console.log user


# passport.use(new LocalStrategy(User.authenticate()))
# passport.serializeUser(User.serializeUser())
# passport.deserializeUser(User.deserializeUser())

# userRoot = user.root "/"


# userRoot.post (req, res) ->
#     console.log "AHUEHUEHUE"
#     user = new User
#     user.email = req.body.email

#     User.register user, req.body.passowrd, (err, user) ->
#         if err
#             logger.debug err: err, "error registering user"

#         passport.authenticate('local') req, res ->
#             logger.debug "success"

# userRoot.get (req, res) ->
#     console.log "SÖRS"

# module.exports =
#     user: user
