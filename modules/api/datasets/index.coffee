"use strict"

{Router} = require "express"
passport = require "passport"
mongoose = require "mongoose"
{BasicStrategy:BasicStrategy} = require "passport-http"

config   = require "../../config"
errorHandler   = require "../../helper/error-handler"

{dataset:logger}   = require "../../logger"

{model:Dataset} = require "./dataset"

dataset = Router()

ObjectId = mongoose.Schema.Types.ObjectId

basicAuth = passport.authenticate "basic",  session: false

datasetRoot = dataset.route "/"

###
@api {post} dataset/ POST - create a dataset
@apiName addDataset
@apiGroup Dataset
@apiVersion 0.0.1
@apiDescription Create a new Dataset

@apiParam {String} name  Name of the dataset
@apiParam {String} userId  ID of the user who created the dataset
@apiParam {Object} data  Data to be saved
@apiParam {Object} options  Options of the visualization


@apiExample {curl} Example usage:
    curl http://localhost:3000/v0/datasets -u admin:admin -H "Content-Type: application/json" -d '{"name": "vidatio", "data":{"key1": "value1"}}'

@apiUse basicAuth
@apiUse SuccessDataset
@apiUse ErrorHandler
###

datasetRoot.post basicAuth, (req, res) ->
    dataset = new Dataset

    dataset.userId = req.user._id
    dataset.name = req.body.name
    dataset.data = req.body.data
    dataset.options = req.body.options

    dataset.save (error, dataset) ->
        if error
            logger.debug error: error, "error saving dataset"
            error = errorHandler.format error
            return res.status(500).json error: error

        logger.info dataset: dataset, "success saving dataset"

        return res.json
            _id: dataset._id
            name: dataset.name
            userId: dataset.userId
            data: dataset.data
            options: dataset.options
            createdAt: dataset.createdAt

datasetIdRoot = dataset.route "/:id"

###
@api {delete} dataset/:id/ DELETE - delete a Dataset by Id
@apiName deleteDataset
@apiGroup Dataset
@apiVersion 0.0.1

@apiDescription Delete a Dataset by Id. This doesn't really delete the Dataset,
a deleted flag is set to true.

@apiExample {curl} Example usage:
    curl -u admin:admin -X DELETE http://localhost:3000/v0/datasets/56376b6406e4eeb46ad32b5

@apiUse basicAuth
@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "message": "successfully deleted dataset"
    }
@apiErrorExample {status} Error-Response:
    HTTP/1.1 404 Not Found
    {
        error: "not found"
    }
@apiUse ErrorHandler
###

datasetIdRoot.delete basicAuth, (req, res) ->
    logger.debug id: req.params.id, "delete a dataset by id"

    Dataset.findOneAndUpdate {
        _id: req.params.id
    },  {
        $set: {
            deleted: true
        }
    }, {
        "new": true
    }, (error, dataset) ->
        if error
            logger.error error: error, "wasn't able to update dataset"
            error = errorHandler.format error
            return res.status(500).json error: error
        else
            if not dataset? or !dataset.deleted
                return res.status(404).json error: "not found"

            logger.debug dataset: dataset, "successfully updated dataset"
            res.json message: "successfully deleted dataset"

module.exports =
    dataset: dataset
