"use strict"

{Router} = require "express"
passport = require "passport"
{BasicStrategy:BasicStrategy} = require "passport-http"

config   = require "../../config"

{user:logger}   = require "../../logger"

{model:User} = require "./user"

user = Router()

passport.use new BasicStrategy ( username, password, done ) ->
    User.findOne
        username: username
    , ( error, user ) ->
        return done error if error
        return done null, false if !user
        return done null, false if !user.authenticate password
        return done null, user


passport.serializeUser ( user, done ) ->
    done null, user._id

passport.deserializeUser ( id, done ) ->
    User.findById id, ( err, user ) ->
        done err, user

basicAuth = passport.authenticate "basic",  session: false

userRoot = user.route "/"


###
@api {post} user/ POST - register a user
@apiName addUser
@apiGroup User
@apiVersion 0.0.1
@apiDescription Register a new User

@apiParam {String} email  Users' email
@apiParam {String} password  Users' password

@apiUse SuccessUser
###
userRoot.post ( req, res ) ->
    user = new User

    user.email = req.body.email
    user.username = req.body.email
    user.password = req.body.password

    user.save ( error, user ) ->
        if error
            console.log "if user save error"
            logger.debug error: error, "error registering user"
            return res.status( 500 ).json error: error

        console.log "success registering user"
        logger.info user: user, "success registering user"
        req.login user, ( error ) ->
            if error
                console.log "error login user"
                console.log error
                logger.debug error: error, "error login new user"
                return res.status( 500 ).json error: error

            console.log "success login user"
            logger.info user: user, "success login new user"
            return res.json
                _id: user._id
                username: user.username
                email: user.email
                deleted: user.deleted


userIdRoot = user.route "/:id"

###
@api {delete} user/:id/ DELETE - delete a User by Id
@apiName deleteUser
@apiGroup User
@apiVersion 0.0.1

@apiDescription Delete a User by Id. This doesn't really deletes the User,
a deleted flag is set to True and the name of the User is changed (to prevent
conflicts when creating a User with the same name later).

@apiUse SuccessUser
###

userIdRoot.delete ( req, res ) ->
    logger.debug id: req.params.id, "delete a user by id"

    User.findById req.params.id, "id name", ( error, user ) ->
        if error
            logger.error error: error, "wasn't able to get user"
            res.status( 500 ).json error: error
        else
            if not user? or user.deleted
                return res.status( 404 ).json error: "not found"

            user.deleted = true
            user.username = "#{ user.username }:#{ user.email }"
            user.save ( error ) ->
                if error
                    logger.error error: error, "wasn't able to save user"

                    res.status( 500 ).json error: error
                else
                    logger.debug user: user, "return user"
                    res.json message: "successfully deleted user"

module.exports =
    user: user
