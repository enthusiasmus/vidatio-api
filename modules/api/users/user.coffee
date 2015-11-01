"use strict"

mongoose = require "mongoose"
validate = require "mongoose-validator"
basic = require "basic-auth-mongoose"

db = require "../connection"


emailValidator = [
    validate
        validator: "isEmail"
        message: "API.USER.REGISTER.EMAIL.NOTVALID"
]

userSchema = mongoose.Schema
    email:
        type: String
        trim: true
        unique: true
        required: true
        validate: emailValidator
    username:
        type: String
        trim: true
        unique: true
        required: true
    deleted:
        type: Boolean
        required: true
        default: false
    admin:
        type: Boolean
        required: true
        default: false


userSchema.plugin basic
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
@apiSuccess {String} user.username Contains the users' username
@apiSuccess {String} user.email Contains the users' email
@apiSuccess {String} user.salt Contains the users' salt of password
@apiSuccess {String} user.hash Contains the users' password as hash
@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "_id": "5635ed0505b07e9c1ade03b4",
        "username": "test@test.com",
        "email": "test@test.com",
        "deleted": false
    }
###
