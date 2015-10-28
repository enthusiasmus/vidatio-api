"use strict"

mongoose = require "mongoose"
passportLocalMongoose = require "passport-local-mongoose"

db        = require "../connection"

userSchema = mongoose.Schema
    email:
        type: String
        trim: true
        unique: true
        required: true
    password:
        type: String
        required: true
    deleted:
        type: Boolean
        required: true
        default: false

userSchema.plugin passportLocalMongoose

userModel = db.model "User", userSchema

module.exports =
    schema: userSchema
    model:  userModel


###
@apiDefine SuccessUser
@apiVersion 0.0.1
@apiSuccess {Object}   user
@apiSuccess {ObjectId} user._id Contains the users' name
@apiSuccess {Number}   user.__v Internal Revision of the document.
@apiSuccess {String}   user.email Contains the users' name
@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "name": "Fritz",
        "_id": "544e18b3423922a6019473aa",
    }
###

###
@apiDefine SuccessPenguins
@apiVersion 0.0.1
@apiSuccess {Object[]} penguins
@apiSuccess {ObjectId} penguins._id Contains the penguins' name
@apiSuccess {Number}   penguins.__v Internal Revision of the document.
@apiSuccess {String}   penguins.name Contains the penguins' name
@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    [
        {
            "name": "Fritz",
            "_id": "544e18b3423922a6019473aa",
        },
        {
            "name": "Hias",
            "_id": "544e18b3423922a6019473ae",
        }
    ]
###
