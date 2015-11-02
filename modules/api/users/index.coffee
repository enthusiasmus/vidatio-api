"use strict"

{Router} = require "express"
passport = require "passport"
{BasicStrategy:BasicStrategy} = require "passport-http"

config   = require "../../config"

{user:logger}   = require "../../logger"

{model:User} = require "./user"

user = Router()


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
userRoot.post (req, res) ->
    user = new User

    user.email = req.body.email
    user.name = req.body.name
    user.password = req.body.password

    user.save (error, user) ->
        if error
            console.log "if user save error"
            logger.debug error: error, "error registering user"
            return res.status(500).json error: error

        console.log "success registering user"
        logger.info user: user, "success registering user"
        # req.login user, ( error ) ->
        #     if error
        #         console.log "error login user"
        #         console.log error
        #         logger.debug error: error, "error login new user"
        #         return res.status( 500 ).json error: error

        #     console.log "success login user"
        #     logger.info user: user, "success login new user"
        return res.json
            _id: user._id
            name: user.name
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

userIdRoot.delete basicAuth, (req, res) ->
    logger.debug id: req.params.id, "delete a user by id"

    User.findById req.params.id, "id name", (error, user) ->
        if error
            logger.error error: error, "wasn't able to get user"
            res.status(500).json error: error
        else
            if not user? or user.deleted
                return res.status(404).json error: "not found"

            user.deleted = true
            user.username = "#{ user.username }:#{ user.email }"
            user.save ( error ) ->
                if error
                    logger.error error: error, "wasn't able to save user"

                    res.status(500).json error: error
                else
                    logger.debug user: user, "return user"
                    res.json message: "successfully deleted user"


userCheckRoot = user.route "/check"
userCheckRoot.get (req, res) ->
    for key, value of req.query
        switch key
            when "email", "name"
                obj = "#{key}": value
                User.findOne obj, (error, user) ->
                    return res.status(500).json error: error if error
                    return res.status(404).json error: error if not user? or user.deleted
                    return res.status(200).json message: value + " available"

module.exports =
    user: user
