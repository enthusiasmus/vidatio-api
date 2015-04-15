"use strict"

mongoose = require "mongoose"

db        = require "../connection"


penguinSchema = mongoose.Schema
    name:
        type: String
        required: true
        unique: true
        default: ""
    deleted:
        type: Boolean
        required: true
        default: false

penguinModel = db.model "Penguin", penguinSchema

module.exports =
    schema: penguinSchema
    model:  penguinModel


###
@apiDefine SuccessPenguin
@apiVersion 0.0.1
@apiSuccess {Object}   penguin
@apiSuccess {ObjectId} penguin._id Contains the penguins' name
@apiSuccess {Number}   penguin.__v Internal Revision of the document.
@apiSuccess {String}   penguin.name Contains the penguins' name
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
