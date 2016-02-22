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

@apiExample {curl} Example usage:
    curl http://localhost:3000/v0/users -H "Content-Type: application/json" -d '{"email": "admin@admin.com", "name":"admin", "password": "admin"}'

@apiUse SuccessUser
@apiUse ErrorHandler
###

userRoot.post (req, res) ->
    logger.info "creating new user"
    logger.debug params: req.body

    user = new User

    user.email = req.body.email
    user.name = req.body.name
    user.password = req.body.password

    user.save (error, user) ->
        if error?
            logger.error error: error, "error registering user"
            error = errorHandler.format error
            return res.status(500).json error: error

        logger.debug user: user, "success registering user"

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

@apiExample {curl} Example usage:
    curl -u admin:admin -X DELETE http://localhost:3000/v0/users/56376b6406e4eeb46ad32b5

@apiUse basicAuth
@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "message": "successfully deleted user"
    }
@apiErrorExample {status} Error-Response:
    HTTP/1.1 404 Not Found
    {
        error: "not found"
    }
@apiUse ErrorHandler
###

userIdRoot.delete basicAuth, (req, res) ->
    logger.info "delete a user by id"
    logger.debug params: req.params

    User.findOneAndUpdate {
        _id: req.params.id
    },  {
        name: "#{ user.name }:#{ user.email }"
        email: "#{ user.name }:#{ user.email }"
        deleted: true
    }, {
        "new": true
    }, (error, user) ->
        if error?
            logger.error error: error, "wasn't able to update user"
            error = errorHandler.format error
            return res.status(500).json error: error
        else
            if not user? or !user.deleted
                logger.error error: "user not found or already deleted"
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
        "message": "user not found"
        "available": true
    }

@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "message": "user@admin.com not available"
        "available": false
    }
@apiErrorExample {status} Error-Response:
    HTTP/1.1 404 Not Found
    {
        error: "not found"
    }
###

userCheckRoot.get (req, res) ->
    logger.info "check if user with email or username already exists"
    logger.info params: req.query

    for key, value of req.query
        switch key
            when "email", "name"
                obj = "#{key}": value
                User.findOne obj, (error, user) ->
                    if error?
                        logger.error error: error, "wasn't able to find user by #{key}"
                        error = errorHandler.format error
                        return res.status(500).json error: error

                    if not user? or user.deleted
                        logger.error error: error, "wasn't able to find user by #{key}"
                        return res.status(200).json
                            message: "user not found"
                            available: true

                    logger.debug user: user, "found user by #{key}"
                    return res.status(200).json
                        message: value + " not available"
                        available: false
            else
                logger.error error: "wasn't able to handle key #{key}"
                return res.status(404).json error: "not found"

module.exports =
    user: user
