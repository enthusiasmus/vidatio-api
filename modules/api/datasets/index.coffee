"use strict"

{Router} = require "express"
passport = require "passport"
mongoose = require "mongoose"
mongoose.Promise = global.Promise

{BasicStrategy:BasicStrategy} = require "passport-http"

config   = require "../../config"
errorHandler   = require "../../helper/error-handler"
{hasAllProperties, updateObject}   = require "../../helper/util"

{dataset:logger}   = require "../../logger"

{model:Dataset} = require "./dataset"
{model:Tag} = require "../tags/tag"

dataset = Router()

ObjectId = mongoose.Schema.Types.ObjectId

basicAuth = passport.authenticate "basic",  session: false

datasetRoot = dataset.route "/"

###
@api {get} datasets/ GET - get all Datasets
@apiName getDatasets
@apiGroup Datasets
@apiVersion 0.0.1
@apiDescription Get all available Datasets

@apiExample {curl} Example usage:
    curl http://localhost:3000/v0/datasets

@apiUse SuccessDatasets
@apiUse ErrorHandler
###

datasetRoot.get (req, res) ->
    logger.info "get all datasets"
    logger.debug params: req.body

    Dataset.find deleted: false, "id name userId data options createdAt"
    .populate "userId", "name -_id"
    .exec (error, datasets) ->
        if error?
            logger.error error: error, "error retrieving datasets"
            error = errorHandler.format error
            return res.status(500).json error: error
        else
            unless datasets?
                datasets = []

            logger.debug datasets: datasets, "return datasets"
            return res.status(200).json datasets


###
@api {post} datasets/ POST - create a dataset
@apiName addDataset
@apiGroup Datasets
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
    logger.info "creating new dataset"
    logger.debug params: req.body

    unless hasAllProperties req.body, ["data"]
        return res.status(500).json error: "To save a dataset at least some data need to be presend"

    dataset = new Dataset

    dataset.userId = req.user._id
    updateObject req.body, ["name", "data", "options"], dataset
    promiseArray = []
    if req.body.metaData?
        dataset.metaData = {}
        if req.body.metaData.tags?
            dataset.metaData.tags = []
            for tag in req.body.metaData.tags
                promiseArray.push findOrCreateTag tag, dataset

        if req.body.metaData.categories?
            for category in req.body.metaData.categories
                dataset.metaData.categories.push category

    Promise.all(promiseArray)
    .then (result) ->
        dataset.save (error, dataset) ->
            if error?
                logger.error error: error, "error saving dataset"
                error = errorHandler.format error
                return res.status(500).json error: error

            logger.debug dataset: dataset, "success saving dataset"

            return res.json dataset
    , (error) ->
        return res.status(500).json error: "A strange error occured"



findOrCreateTag = (tag, dataset) ->
    return new Promise (resolve, reject) ->
        Tag.findOrCreate tag, (error, tag) ->
            reject error if error?
            dataset.metaData.tags.push tag._id
            resolve tag

datasetIdRoot = dataset.route "/:id"

###
@api {delete} datasets/:id/ DELETE - delete a Dataset by Id
@apiName deleteDataset
@apiGroup Datasets
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
    logger.info "delete a dataset by id"
    logger.debug params: req.params

    Dataset.findOneAndUpdate {
        _id: req.params.id
    },  {
        $set: {
            deleted: true
        }
    }, {
        "new": true
    }, (error, dataset) ->
        if error?
            logger.error error: error, "wasn't able to update dataset"
            error = errorHandler.format error
            return res.status(500).json error: error
        else
            if not dataset? or !dataset.deleted
                logger.error error: "dataset not found or already deleted"
                return res.status(404).json error: "not found"

            logger.debug dataset: dataset, "successfully updated dataset"
            res.json message: "successfully deleted dataset"

###
@api {get} dataset/:id/ GET - get a dataset by Id
@apiName getDataset
@apiGroup Dataset
@apiVersion 0.0.1

@apiDescription Get a Dataset by Id.

@apiExample {curl} Example usage:
    curl http://localhost:3000/v0/datasets/56376b6406e4eeb46ad32b5

@apiUse SuccessDataset
@apiUse ErrorHandler
@apiErrorExample {status} Error-Response:
    HTTP/1.1 404 Not Found
    {
        error: "not found"
    }
###

datasetIdRoot.get (req, res) ->
    logger.info "get a dataset by id"
    logger.debug params: req.params

    Dataset.findById req.params.id
    .populate "userId", "name email"
    .exec (error, dataset) ->
        if error?
            console.log error
            logger.error error: error, "wasn't able to get dataset"
            error = errorHandler.format error
            return res.status(500).json error: error
        else
            if not dataset? or dataset.deleted
                logger.error error: "dataset not found or deleted"
                return res.status(404).json error: "not found"

            logger.debug dataset: dataset, "return dataset"
            res.json dataset

module.exports =
    dataset: dataset
