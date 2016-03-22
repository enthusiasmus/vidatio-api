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
        message: "API.ERROR.DATASET.CREATE.NAME.NOTVALID"
]

metaDataSchema = mongoose.Schema
    name:
        required: "API.ERROR.DATASET.CREATE.NAME.REQUIRED"
        validate: nameValidator
        type: String

    author:
        type: String

    fileType:
        required: "API.ERROR.DATASET.CREATE.FILETYPE.REQUIRED"
        type: String

    tagIds: [
        ref: "Tag"
        type: mongoose.Schema.Types.ObjectId
    ]

    userId:
        ref: "User"
        type: mongoose.Schema.Types.ObjectId
        required: "API.ERROR.DATASET.CREATE.USER_ID.REQUIRED"

    categoryId:
        ref: "Category"
        required: "API.ERROR.DATASET.CREATE.CATEGORY.REQUIRED"
        type: mongoose.Schema.Types.ObjectId

datasetSchema = mongoose.Schema
    data:
        type: mongoose.Schema.Types.Mixed
        required: true

    published:
        type: Boolean
        required: true
        default: true

    metaData: metaDataSchema

    visualizationOptions:
        type: mongoose.Schema.Types.Mixed
        required: "API.ERROR.DATASET.CREATE.VISUALIZATION_OPTIONS.REQUIRED"


datasetSchema.plugin timestamps
datasetModel = db.model "Dataset", datasetSchema
module.exports =
    schema: datasetSchema
    model:  datasetModel

###
@apiDefine SuccessDataset
@apiSuccess {Object} dataset
@apiSuccess {ObjectId} dataset._id Contains the datasets' object id
@apiSuccess {Number} dataset.__v Internal Revision of the document.
@apiSuccess {Boolean} dataset.published Tells if the dataset is published on our client or not.
@apiSuccess {Date} dataset.createdAt Date when the dataset was created
@apiSuccess {Date} dataset.updatedAt Date when the dataset was updated

@apiSuccess {Object} dataset.metaData contains all meta-data of the given dataset
@apiSuccess {Object} dataset.metaData.categoryId contains the category object of the given dataset
@apiSuccess {Object} dataset.metaData.userId contains the user who saved the dataset
@apiSuccess {String} dataset.metaData.fileType fileType of saved dataset
@apiSuccess {String} dataset.metaData.name name of the dataset
@apiSuccess {Array} [dataset.metaData.tagIds]
@apiSuccess {Object} dataset.metaData.tagIds.tag a tag object of the given dataset

@apiSuccess {Object} dataset.visualizationOptions contains all saved options of our dataset
@apiSuccess {String} dataset.visualizationOptions.type contains the type of a visualization
@apiSuccess {Integer} dataset.visualizationOptions.xColumn contains the used x-colum of a visualization
@apiSuccess {Integer} dataset.visualizationOptions.yColumn contains the used y-colum of a visualization
@apiSuccess {String} dataset.visualizationOptions.color contains the hex-encoded color of a visualization
@apiSuccess {Boolean} dataset.visualizationOptions.useColumnHeadersFromDataset tells if the visualization should use the header  from the given dataset

@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    UPDATE CORRECT EXAMPLE
    {
        "_id": "56f17533589e927d08a72dd2",
        "createdAt": "2016-03-22T16:39:15.632Z",
        "updatedAt": "2016-03-22T16:39:15.632Z",
        "visualizationOptions": {
            "option1": "option1"
        },
        "data": {
            "key1": "value1"
        },
        "metaData": {
            "categoryId": "56f167a70c2d232845af14c4",
            "fileType": "csv",
            "name": "First Dataset",
            "userId": "56f175335ace5d610fd3272d",
            "tagIds": []
        },
        "__v": 0,
        "published": true
    }
###

###
@apiDefine SuccessDatasets
@apiSuccess {Object[]} datasets list of datasets
@apiSuccess {Object} datasets.dataset a single dataset object in the list
@apiSuccess {ObjectId} datasets.dataset._id Contains the datasets' object id
@apiSuccess {Number} datasets.dataset.__v Internal Revision of the document.
@apiSuccess {Boolean} datasets.dataset.published Tells if the dataset is published on our client or not.
@apiSuccess {Date} datasets.dataset.createdAt Date when the dataset was created
@apiSuccess {Date} datasets.dataset.updatedAt Date when the dataset was updated

@apiSuccess {Object} datasets.dataset.metaData contains all meta-data of the given dataset
@apiSuccess {Object} datasets.dataset.metaData.categoryId contains the category object of the given dataset
@apiSuccess {Object} datasets.dataset.metaData.userId contains the user who saved the dataset
@apiSuccess {String} datasets.dataset.metaData.fileType fileType of saved dataset
@apiSuccess {String} datasets.dataset.metaData.name name of the dataset
@apiSuccess {Array} [datasets.dataset.metaData.tagIds]
@apiSuccess {Object} datasets.dataset.metaData.tagIds.tag a tag object of the given dataset

@apiSuccess {Object} datasets.dataset.visualizationOptions contains all saved options of our dataset
@apiSuccess {String} datasets.dataset.visualizationOptions.type contains the type of a visualization
@apiSuccess {Integer} datasets.dataset.visualizationOptions.xColumn contains the used x-colum of a visualization
@apiSuccess {Integer} datasets.dataset.visualizationOptions.yColumn contains the used y-colum of a visualization
@apiSuccess {String} datasets.dataset.visualizationOptions.color contains the hex-encoded color of a visualization
@apiSuccess {Boolean} datasets.dataset.visualizationOptions.useColumnHeadersFromDataset tells if the visualization should use the header  from the given dataset

@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    UPDATE CORRECT EXAMPLE
     [
        {
            "_id": "56f17533589e927d08a72dd2",
            "createdAt": "2016-03-22T16:39:15.632Z",
            "updatedAt": "2016-03-22T16:39:15.632Z",
            "visualizationOptions": {
                "option1": "option1"
            },
            "data": {
                "key1": "value1"
            },
            "metaData": {
                "categoryId": "56f167a70c2d232845af14c4",
                "fileType": "csv",
                "name": "First Dataset",
                "userId": "56f175335ace5d610fd3272d",
                "tagIds": []
            },
            "__v": 0,
            "published": true
        },
        {
            "_id": "56f17533589e927d08a72dd2",
            "createdAt": "2016-03-22T16:39:15.632Z",
            "updatedAt": "2016-03-22T16:39:15.632Z",
            "visualizationOptions": {
                "option1": "option1"
            },
            "data": {
                "key1": "value1"
            },
            "metaData": {
                "categoryId": "56f167a70c2d232845af14c4",
                "fileType": "csv",
                "name": "First Dataset",
                "userId": "56f175335ace5d610fd3272d",
                "tagIds": []
            },
            "__v": 0,
            "published": true
        },
     ]
###
