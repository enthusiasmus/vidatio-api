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
{model:Category} = require "../categories/category"

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

    Dataset.find {}
    .populate "metaData.userId metaData.category metaData.tags"
    .sort
        "createdAt": -1
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
@apiParam {Object} metaData  metaData of the current Dataset like "name", "tags", and "categories"

@apiExample {curl} Example usage:
    curl http://localhost:3000/v0/datasets -u admin:admin -H "Content-Type: application/json" -d '{"name": "vidatio", "data":{"key1": "value1"}}'

@apiUse basicAuth
@apiUse SuccessDataset
@apiUse ErrorHandler
###

datasetRoot.post basicAuth, (req, res) ->
    logger.info "creating new dataset"
    logger.debug params: req.body

    unless hasAllProperties req.body, ["data", "visualizationOptions", "metaData"]
        return res.status(500).json error: "To save a dataset the following keys must be present: [data, visualizationOptions, metaData]"

    dataset = new Dataset
        metaData: {}


    dataset.metaData.userId = req.user._id
    dataset.metaData.name = req.body.metaData.name
    dataset.metaData.fileType = req.body.metaData.fileType
    dataset.metaData.categoryId = req.body.metaData.categoryId

    dataset.data = req.body.data
    dataset.visualizationOptions = req.body.visualizationOptions

    tagsPromiseArray = []
    if req.body.metaData.tags?
        dataset.metaData.tagIds = []
        for tag in req.body.metaData.tags
            tagsPromiseArray.push findOrCreateTag tag, dataset

    Promise.all tagsPromiseArray
    .then (result) ->
        dataset.save (error) ->
            if error?
                logger.error
                    error: error
                    dataset: dataset
                , "error saving dataset"
                error = errorHandler.format error
                return res.status(500).json error: error

            logger.debug dataset: dataset, "success saving dataset"

            return res.json dataset
    , (error) ->
        return res.status(500).json error: "Error saving dataset"

findOrCreateTag = (tag, dataset) ->
    return new Promise (resolve, reject) ->
        Tag.findOrCreate tag, (error, tag) ->
            reject error if error?
            dataset.metaData.tagIds.push tag._id
            resolve tag

datasetIdRoot = dataset.route "/:id"

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
    .populate "metaData.category metaData.tags", "name -_id"
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
