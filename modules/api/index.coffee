"use strict"

{Router} = require "express"
passport = require "passport"
{BasicStrategy} = require "passport-http"

{penguin,penguins} = require "./penguins"

{_import} = require "./import"

{routes:logRoutes, api:logger} = require "../logger"

router = Router()


# never use this in production envs, only used to show basic auth
users = [
    {
        username: "admin"
        password: "admin"
        isAdmin: true
    }
    {
        username: "user"
        password: "user"
        isAdmin: false
    }
]

passport.use new BasicStrategy {}, ( username, password, done ) ->
    # do some fancy real auth stuff here (maybe move to user model)
    for user in users
        if user.username is username and user.password is password
            logger.info
                user: user
                username: username
                password: password
            , "user auth successfull"
            return done null, user

    logger.warn
        username: username
        password: password
    , "user auth failed"
    return done(null, false)


router.use "/penguin", penguin
router.use "/penguin", penguins

router.get "/auth", passport.authenticate( "basic",  session: false ), ( req, res ) ->
    res.json name: req.user.username

router.use "/import", _import

router.use "/logs", logRoutes

router.all "/*", (req, res) ->
    logger.error req: req, "not found!"

    res.status( 404 ).json error: "not found"


module.exports = router
