"use strict"

mongoose = require "mongoose"
validate = require "mongoose-validator"
crypto = require "crypto"

db = require "../connection"

nameValidator = [
    validate
        validator: "matches"
        arguments: /^[\w\s_.-]+$/
        message: "API.ERROR.CATEGORY.NAME.NOTVALID"
]

categorySchema = mongoose.Schema
    name:
        type: String
        trim: true
        unique: true
        required: "API.ERROR.CATEGORY.NAME.REQUIRED"
        validate: nameValidator


categoryModel = db.model "Category", categorySchema
module.exports =
    schema: categorySchema
    model:  categoryModel

###
@apiDefine SuccessCategory
@apiSuccess {Object} category
@apiSuccess {ObjectId} category._id Contains the categories' object id
@apiSuccess {String} category.name Name of the category.

@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "_id": "56f167a70c2d232845af14c4",
        "name": "Politik"
    }
###
