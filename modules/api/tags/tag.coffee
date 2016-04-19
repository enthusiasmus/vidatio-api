"use strict"

mongoose = require "mongoose"
timestamps = require "mongoose-timestamp"
db = require "../connection"

tagSchema = mongoose.Schema
    name:
        type: String
        required: "API.ERROR.TAG.CREATE.NAME.REQUIRED"
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
@apiDefine SuccessTags
@apiSuccess {Object[]} tags list of tags
@apiSuccess {Object} tags.tag tag
@apiSuccess {ObjectId} tags.tag._id Contains the tag' object id
@apiSuccess {Number} tags.tag.__v Internal revision of the document
@apiSuccess {String} tags.tag.name Name of the tag

@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "_id": "5635ed0505b07e9c1ade03b4",
        "name": "test",
    }
###
