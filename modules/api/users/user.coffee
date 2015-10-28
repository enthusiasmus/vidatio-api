"use strict"

mongoose = require "mongoose"
passportLocalMongoose = require "passport-local-mongoose"

db = require "../connection"

userSchema = mongoose.Schema
    email:
        type: String
        trim: true
        unique: true
        required: true
    password:
        type: String
    deleted:
        type: Boolean
        required: true
        default: false

userSchema.plugin passportLocalMongoose,
    usernameField: 'email'

userModel = db.model "User", userSchema

module.exports =
    schema: userSchema
    model:  userModel


###
@apiDefine SuccessUser
@apiVersion 0.0.1
@apiSuccess {Object} user
@apiSuccess {ObjectId} user._id Contains the users' object id
@apiSuccess {Number} user.__v Internal Revision of the document.
@apiSuccess {String} user.email Contains the users' email
@apiSuccess {String} user.salt Contains the users' salt of password
@apiSuccess {String} user.hash Contains the users' password as hash
@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "name": "Fritz",
        "_id": "544e18b3423922a6019473aa",
    }
###
