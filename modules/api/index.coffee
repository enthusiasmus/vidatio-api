"use strict"

{Router} = require "express"
passport = require "passport"
{BasicStrategy} = require "passport-http"

{model:User} = require "./users/user"

{forward} = require "./forward"
{user} = require "./users"
{auth} = require "./auth"
{dataset} = require "./datasets"

{routes:logRoutes, auth:logger} = require "../logger"

router = Router()

passport.use new BasicStrategy (nameOrEmail, password, done) ->
    User.findByNameOrEmail nameOrEmail, (error, user) ->
        return done error if error
        return done null, false if !user
        return done null, false if !user.authenticate password

        logger.info
            user: user
            name: user.name
            email: user.email
            password: password
        , "user auth successful"
        return done null, user

router.use "/forward", forward
router.use "/users", user
router.use "/auth", auth
router.use "/datasets", dataset


router.use "/logs", logRoutes

router.all "/*", (req, res) ->
    logger.error req: req, "not found!"

    res.status(404).json error: "not found"


module.exports = router
