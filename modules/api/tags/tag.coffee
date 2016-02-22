"use strict"

mongoose = require "mongoose"
validate = require "mongoose-validator"
{extend} = validate
timestamps = require "mongoose-timestamp"
db = require "../connection"

nameValidator = [
    validate
        validator: "matches"
        arguments: /^[\w\s_.-]+$/
        message: "API.TAG.CREATE.NAME.NOTVALID"
]

tagSchema = mongoose.Schema
    name:
        type: String
        required: "API.TAG.CREATE.NAME.REQUIRED"
        validate: nameValidator
        unique: true
        trim: true

tagSchema.statics =
    findOrCreate: (tagName, cb) ->
        @findOne
            name: tagName
        , (error, tag) =>
            return cb null, tag if tag?

            tag = new @
                name: tagName
            tag.save (error, tag) ->
                return cb error, tag

tagModel = db.model "Tag", tagSchema
module.exports =
    schema: tagSchema
    model:  tagModel


###
@apiDefine SuccessTag
@apiVersion 0.0.1
@apiSuccess {Object} tag
@apiSuccess {ObjectId} tag._id Contains the tag' object id
@apiSuccess {Number} tag.__v Internal Revision of the document.
@apiSuccess {String} tag.name Name of the tag.

@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "_id": "5635ed0505b07e9c1ade03b4",
        "name": "test",
    }
###
