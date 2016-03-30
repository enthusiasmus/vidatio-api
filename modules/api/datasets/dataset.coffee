"use strict"

mongoose = require "mongoose"
validate = require "mongoose-validator"
{extend} = validate
timestamps = require "mongoose-timestamp"
db = require "../connection"

nameValidator = [
    validate
        validator: "matches"
        arguments: /^[\w\s_.-\/]+$/
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
    {
      "_id": "56f27b9fa642da4f431e3c27",
      "createdAt": "2016-03-23T11:18:55.647Z",
      "updatedAt": "2016-03-23T11:18:55.647Z",
      "data": [
        [
          47.723955,
          13.08485,
          "Bank"
        ],
        [
          47.725081,
          13.087736,
          "Post"
        ],
      ],
      "metaData": {
        "name": "Seed Dataset Map",
        "fileType": "csv",
        "categoryId": {
          "_id": "56f27b9fa4e454961211c226",
          "name": "Sport"
        },
        "userId": {
          "_id": "56f27b9ea642da4f431e3c22",
          "email": "user2@vidatio.com",
          "name": "user2",
          "admin": false
        },
        "tagIds": [
          {
            "_id": "56f27b9fa4e454961211c230",
            "name": "mmt"
          }
        ]
      },
      "visualizationOptions": {
        "type": "map",
        "xColumn": 1,
        "yColumn": 0,
        "color": null,
        "useColumnHeadersFromDataset": false
      },
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
     [
        {
          "_id": "56f27b9fa642da4f431e3c27",
          "createdAt": "2016-03-23T11:18:55.647Z",
          "updatedAt": "2016-03-23T11:18:55.647Z",
          "data": [
            [
              47.723955,
              13.08485,
              "Bank"
            ],
            [
              47.725081,
              13.087736,
              "Post"
            ],
          ],
          "metaData": {
            "name": "Seed Dataset Map",
            "fileType": "csv",
            "categoryId": {
              "_id": "56f27b9fa4e454961211c226",
              "name": "Sport"
            },
            "userId": {
              "_id": "56f27b9ea642da4f431e3c22",
              "email": "user2@vidatio.com",
              "name": "user2",
              "admin": false
            },
            "tagIds": [
              {
                "_id": "56f27b9fa4e454961211c230",
                "name": "mmt"
              }
            ]
          },
          "visualizationOptions": {
            "type": "map",
            "xColumn": 1,
            "yColumn": 0,
            "color": null,
            "useColumnHeadersFromDataset": false
          },
          "published": true
        },
        {
          "_id": "56f27b9fa642da4f431e3c26",
          "createdAt": "2016-03-23T11:18:55.626Z",
          "updatedAt": "2016-03-23T11:18:55.626Z",
          "data": [
            [
              200,
              "Orange"
            ],
            [
              300,
              "Banane"
            ],
            [
              400,
              "Apfel"
            ]
          ],
          "metaData": {
            "name": "Seed Dataset Bar 1",
            "fileType": "csv",
            "categoryId": {
              "_id": "56f27b9fa4e454961211c226",
              "name": "Sport"
            },
            "userId": {
              "_id": "56f27b9ea642da4f431e3c21",
              "email": "user1@vidatio.com",
              "name": "user1",
              "admin": false
            },
            "tagIds": [
              {
                "_id": "56f27b9fa4e454961211c22a",
                "name": "vidatio"
              },
              {
                "_id": "56f27b9fa4e454961211c22d",
                "name": "greatViz"
              }
            ]
          },
          "visualizationOptions": {
            "type": "bar",
            "xColumn": 1,
            "yColumn": 0,
            "color": "#FA05AF",
            "useColumnHeadersFromDataset": false
          },
          "published": true
        }
     ]
###
