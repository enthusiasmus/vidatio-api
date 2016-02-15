"use strict"

mongoose = require "mongoose"
validate = require "mongoose-validator"
crypto = require "crypto"

db = require "../connection"

nameValidator = [
    validate
        validator: "matches"
        arguments: /^[\w\s_.-]+$/
        message: "API.CATEGORY.NAME.NOTVALID"
]

categorySchema = mongoose.Schema
    name:
        type: String
        trim: true
        unique: true
        required: "API.CATEGORY.NAME.REQUIRED"
        validate: nameValidator
    createdAt:
        type: Date
        required: true
        default: Date.now

categoryModel = db.model "Category", categorySchema
module.exports =
    schema: categorySchema
    model:  categoryModel

###
@apiDefine SuccessCategory
@apiVersion 0.0.1
@apiSuccess {Object} category
@apiSuccess {ObjectId} category._id Contains the categories' object id
@apiSuccess {Number} category.__v Internal Revision of the document.
@apiSuccess {String} category.name Name of the category.
@apiSuccess {Date} category.createdAt Date when the category was created


@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "_id": "5635ed0505b07e9c1ade03b4",
        "name": "test",
        "createdAt": Date
    }
###
