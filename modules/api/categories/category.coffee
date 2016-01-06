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
@apiDefine SuccessDataset
@apiVersion 0.0.1
@apiSuccess {Object} dataset
@apiSuccess {ObjectId} dataset._id Contains the datasets' object id
@apiSuccess {Number} dataset.__v Internal Revision of the document.
@apiSuccess {String} dataset.name Name of the dataset.
@apiSuccess {ObjectId} dataset.userId ID of the user who created the dataset.
@apiSuccess {Boolean} dataset.private Tells if the dataset is private.
@apiSuccess {ObjectId} dataset.parentId ID of the parent dataset.
@apiSuccess {Date} dataset.createdAt Date when the dataset was created
@apiSuccess {Date} dataset.updatedAt Date when the dataset was updated
@apiSuccess {Object} dataset.data Data to be saved
@apiSuccess {Object} dataset.options Options of the visualization


@apiSuccess {Boolean} dataset.deleted Tells if the dataset is deleted.
@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "_id": "5635ed0505b07e9c1ade03b4",
        "name": "test",
        "userId": "563debdc6b8c74b7393f1f8d",
        "createdAt": Date
        "data": {
            key1: "value1"
        },
        "options": {
            key1: "option1"
        }
    }
###

###
@apiDefine SuccessDatasets
@apiVersion 0.0.1
@apiSuccess {Object[]} datasets
@apiSuccess {ObjectId} dataset._id Contains the datasets' object id
@apiSuccess {Number} dataset.__v Internal Revision of the document.
@apiSuccess {String} dataset.name Name of the dataset.
@apiSuccess {ObjectId} dataset.userId ID of the user who created the dataset.
@apiSuccess {Boolean} dataset.private Tells if the dataset is private.
@apiSuccess {ObjectId} dataset.parentId ID of the parent dataset.
@apiSuccess {Date} dataset.createdAt Date when the dataset was created
@apiSuccess {Date} dataset.updatedAt Date when the dataset was updated
@apiSuccess {Object} dataset.data Data to be saved
@apiSuccess {Object} dataset.options Options of the visualization
@apiSuccess {Boolean} dataset.deleted Tells if the dataset is deleted.

@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    [
        {
            "_id": "5635ed0505b07e9c1ade03b4",
            "name": "test1",
            "userId": "563debdc6b8c74b7393f1f8d",
            "createdAt": Date
            "data": {
                key1: "value1"
            },
            "options": {
                key1: "option1"
            }
        },
        {
            "_id": "5635ed0505b07e9c1ade03b2",
            "name": "test2",
            "userId": "563debdc6b8c74b7393f1f8d",
            "createdAt": Date
            "data": {
                key1: "value1"
            },
            "options": {
                key1: "option1"
            }
        }
    ]
###
