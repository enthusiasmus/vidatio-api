"use strict"

{Router} = require "express"
passport = require "passport"
{BasicStrategy:BasicStrategy} = require "passport-http"

config   = require "../../config"
errorHandler   = require "../../helper/error-handler"

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
@apiParam {String} name  Users' name
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
            logger.debug error: error, "error registering user"
            error = errorHandler.format error
            return res.status(500).json error: error

        logger.info user: user, "success registering user"

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

    User.findOneAndUpdate {
        _id: req.params.id
    },  {
        name: "#{ user.name }:#{ user.email }"
        email: "#{ user.name }:#{ user.email }"
        deleted: true
    }, {
        "new": true
    }, (error, user) ->
        if error
            logger.error error: error, "wasn't able to update user"
            error = errorHandler.format error
            return res.status(500).json error: error
        else
            if not user? or !user.deleted
                return res.status(404).json error: "not found"

            logger.debug user: user, "successfully updated user"
            res.json message: "successfully deleted user"

userCheckRoot = user.route "/check"

###
@api {check} user/check?email&name GET - check if a username or email exists
@apiName checkUser
@apiGroup User
@apiVersion 0.0.1

@apiDescription Check if the given username or email is already in the database.

@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "message": "email / name available
    }
###

userCheckRoot.get (req, res) ->
    for key, value of req.query
        switch key
            when "email", "name"
                obj = "#{key}": value
                User.findOne obj, (error, user) ->
                    if error
                        logger.error error: error, "wasn't able to find user by #{key}"
                        error = errorHandler.format error
                        return res.status(500).json error: error

                    if not user? or user.deleted
                        return res.status(200).json
                            message: "user not found"
                            available: true

                    logger.debug user: user, "found user by #{key}"
                    return res.status(200).json
                        message: value + " not available"
                        available: false

module.exports =
    user: user
