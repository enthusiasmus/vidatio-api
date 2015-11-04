"use strict"

mongoose = require "mongoose"
validate = require "mongoose-validator"
{extend} = require "mongoose-validator"
crypto = require "crypto"

db = require "../connection"


emailValidator = [
    validate
        validator: "isEmail"
        message: "API.USER.REGISTER.EMAIL.NOTVALID"
]

extend "isName", (val) ->

nameValidator = [
    validate
        validator: "matches"
        arguments: /^[\w_.-]+$/
        message: "API.USER.REGISTER.NAME.NOTVALID"
]

userSchema = mongoose.Schema
    email:
        type: String
        trim: true
        unique: true
        required: "API.USER.REGISTER.EMAIL.REQUIRED"
        validate: emailValidator
    name:
        type: String
        trim: true
        unique: true
        required: "API.USER.REGISTER.NAME.REQUIRED"
        validate: nameValidator
    deleted:
        type: Boolean
        required: true
        default: false
    admin:
        type: Boolean
        required: true
        default: false
    hash:
        type: String
        required: true
    salt:
        type: String
        required: true

userSchema.virtual("password").set (password) ->
    @salt = @makeSalt()
    @hash = @encryptPassword password

userSchema.methods =
    makeSalt: ->
        return Math.round( new Date().valueOf() * Math.random() ) + ""

    encryptPassword: (password) ->
        return ""  unless password
        try
            return crypto.createHmac("sha1", @salt)
                .update(password)
                .digest("hex")
        catch err
            return ""
        return

    authenticate: (password) ->
        return true if @encryptPassword(password) is @hash

userSchema.statics =
    findByNameOrEmail: (nameOrEmail, cb) ->
        @findOne
            $or: [
                { email: nameOrEmail }
                { name: nameOrEmail }
            ]
        , (error, user) ->
            return cb error, user


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
@apiSuccess {String} user.name Contains the users' username.
@apiSuccess {String} user.email Contains the users' email.
@apiSuccess {String} user.salt Contains the users' salt of password.
@apiSuccess {String} user.hash Contains the users' password as hash.
@apiSuccess {Boolean} user.admin Tells if the user is admin.
@apiSuccess {Boolean} user.deleted Tells if the user is deleted.
@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "_id": "5635ed0505b07e9c1ade03b4",
        "name": "test",
        "email": "test@test.com",
        "deleted": false
        "admin": false
    }
###
