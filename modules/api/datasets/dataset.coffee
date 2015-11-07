"use strict"

mongoose = require "mongoose"
validate = require "mongoose-validator"
{extend} = require "mongoose-validator"
crypto = require "crypto"

db = require "../connection"

ObjectId = mongoose.Schema.Types.ObjectId

#extend "isName", (val) ->

nameValidator = [
    validate
        validator: "matches"
        arguments: /^[\w\s_.-]+$/
        message: "API.DATASET.CREATE.NAME.NOTVALID"
]

datasetSchema = mongoose.Schema
    name:
        type: String
        trim: true
        required: "API.DATASET.CREATE.NAME.REQUIRED"
        validate: nameValidator
    deleted:
        type: Boolean
        required: true
        default: false
    userId:
        type: ObjectId
        required: "API.DATASET.CREATE.USER_ID.REQUIRED"
    parentId:
        type: ObjectId
        required: false
        default: null
    createdAt:
        type: Date
        required: true
        default: Date.now
    updatedAt:
        type: Date
        required: true
        default: Date.now
    data:
        type: Object
        required: true
    options:
        type: Object
        required: false


# datasetSchema.methods =

# datasetSchema.statics =


datasetModel = db.model "Dataset", datasetSchema
module.exports =
    schema: datasetSchema
    model:  datasetModel

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
