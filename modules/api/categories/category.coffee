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


categorySchema.statics =

    findCategory: (category, dataset) ->
        return new Promise (resolve, reject) =>
            @findOne
                name: category
            , (error, doc) ->
                reject error if error?
                if doc then dataset.metaData.category = doc._id else dataset.metaData.category = ""
                resolve doc


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
