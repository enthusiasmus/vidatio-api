"use strict"

{Router} = require "express"
passport = require "passport"
{BasicStrategy} = require "passport-http"

{model:User} = require "./users/user"
{penguin,penguins} = require "./penguins"

{_import} = require "./import"
{user} = require "./users"
{auth} = require "./auth"
{dataset} = require "./datasets"



{routes:logRoutes, api:logger} = require "../logger"

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
        , "user auth successfull"
        return done null, user

router.use "/penguin", penguin
router.use "/penguin", penguins

router.use "/import", _import


router.use "/users", user
router.use "/auth", auth

router.use "/dataset", dataset


router.use "/logs", logRoutes

router.all "/*", (req, res) ->
    logger.error req: req, "not found!"

    res.status(404).json error: "not found"


module.exports = router
