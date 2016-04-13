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
@api {get} datasets?limit/ GET - get all Datasets
@apiName getDatasets
@apiGroup Datasets
@apiVersion 0.0.1
@apiDescription Get all available Datasets

@apiExample {curl} Example usage:
    curl -i https://api.vidatio.com/v0/datasets

@apiUse SuccessDatasets
@apiUse ErrorHandlerMongo
###

datasetRoot.get (req, res) ->
    logger.info "get all datasets"
    logger.debug
        params: req.body
        query: req.query

    limit = if req.query?.limit? then Number(req.query.limit) else 0
    limit = 0 if isNaN(limit)

    Dataset.find
        published: true
    .limit(limit)
    .populate "metaData.userId", "-hash -salt"
    .populate "metaData.categoryId"
    .populate "metaData.tagIds"
    .sort
        "createdAt": -1
    .exec (error, datasets) ->
        if error?
            logger.error error: error, "error retrieving datasets"
            return res.status(500).json error: errorHandler.format error
        else
            unless datasets?
                datasets = []

            logger.debug datasets: datasets, "return datasets"
            return res.status(200).json datasets


###
@api {delete} dataset/:id/ DELETE - delete a dataset by Id
@apiName getDataset
@apiGroup Datasets
@apiVersion 0.0.1

@apiDescription Delete a Dataset by Id. This requires ownership of the given dataset.

@apiExample {curl} Example usage:
    curl -i -X "DELETE" https://api.vidatio.com/v0/datasets/56f17533589e927d08a72dd2 -u username:password'

@apiUse basicAuth
@apiUse SuccessDataset
@apiUse ErrorHandlerMongo
###

datasetIdRoot = dataset.route "/:id"
datasetIdRoot.delete basicAuth, (req, res) ->
    logger.info "delete a dataset by id"
    logger.debug params: req.params

    Dataset.findById req.params.id
    .exec (error, dataset) ->
        unless "#{dataset.metaData.userId}" is "#{req.user._id}"
            logger.error "Deletion of dataset of not authorized user"
            return res.status(401)

        dataset.remove (error, removedDataset) ->
            if error?
                logger.error error: error, "error removing dataset"
                return res.status(200).json errorHandler.format error
            logger.debug removedDataset: removedDataset, "success removing dataset"
            return res.status(204).json {}

###
@api {get} dataset/:id/ GET - get a dataset by Id
@apiName getDataset
@apiGroup Datasets
@apiVersion 0.0.1

@apiDescription Get a Dataset by Id.

@apiExample {curl} Example usage:
    curl -i https://api.vidatio.com/v0/datasets/56f17533589e927d08a72dd2

@apiUse SuccessDataset
@apiUse ErrorHandlerMongo
@apiUse ErrorHandler404
###

datasetIdRoot.get (req, res) ->
    logger.info "get a dataset by id"
    logger.debug params: req.params

    Dataset.findById req.params.id
    .populate "metaData.userId", "-hash -salt"
    .populate "metaData.categoryId"
    .populate "metaData.tagIds"
    .exec (error, dataset) ->
        if error?
            logger.error error: error, "wasn't able to get dataset"
            return res.status(500).json error: errorHandler.format error
        else
            if not dataset?
                logger.error error: "dataset not found"
                return res.status(404).json error: errorHandler.format 404

            logger.debug dataset: dataset, "return dataset"
            res.json dataset


###
@api {post} datasets/ POST - create a dataset
@apiName addDataset
@apiGroup Datasets
@apiVersion 0.0.1
@apiDescription Create a new Dataset

@apiParam {Object} data  The actual data of a dataset as 2D-array or geojson
@apiParam {Object} metaData  metaData of the given dataset

@apiParam {String} metaData.categoryId the categoryId which you want to assign the dataset
@apiParam {String} metaData.fileType fileType of saved dataset
@apiParam {String} metaData.name name of the dataset
@apiParam {String} metaData.author originator of the dataset
@apiParam {Array} [metaData.tagIds]
@apiParam {String} metaData.tagIds.tag each string in the array is going to be used as a tag for your dataset

@apiParam {Object} visualizationOptions  Options for a visualization
@apiParam {String} visualizationOptions.type contains the type of a visualization
@apiParam {Integer} visualizationOptions.xColumn contains the used x-colum of a visualization
@apiParam {Integer} visualizationOptions.yColumn contains the used y-colum of a visualization
@apiParam {String} visualizationOptions.color contains the hex-encoded color of a visualization
@apiParam {Boolean} visualizationOptions.useColumnHeadersFromDataset tells if the visualization should use the header  from the given dataset

@apiExample {curl} Example usage:
    curl -i -X POST https://api.vidatio.com/v0/datasets -H "Content-Type: application/json" -d @testDataFile.json -u username:password'

@apiUse basicAuth
@apiUse SuccessDataset
@apiUse ErrorHandlerValidation
@apiUse ErrorHandlerMongo
@apiUse ErrorHandlerCheckProperties
@apiUse ErrorHandlerPromises
@apiSampleRequest off
###

datasetRoot.post basicAuth, (req, res) ->
    logger.info "creating new dataset"
    logger.debug params: req.body

    unless hasAllProperties req.body, ["data", "visualizationOptions", "metaData"]
        return res.status(500).json error: errorHandler.format
            name: "ParameterError"
            value: "To save a dataset the following keys on body must be present: data, visualizationOptions and metaData"

    dataset = new Dataset
        metaData: {}

    dataset.metaData.userId = req.user._id
    dataset.metaData.name = req.body.metaData.name
    dataset.metaData.fileType = req.body.metaData.fileType
    dataset.metaData.categoryId = req.body.metaData.categoryId
    dataset.metaData.author = req.body.metaData.author

    dataset.data = req.body.data
    dataset.published = req.body.published if req.body.published?
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
                return res.status(500).json error: errorHandler.format error

            logger.debug dataset: dataset, "success saving dataset"

            dataset
            .populate "metaData.userId", "-hash -salt"
            .populate "metaData.categoryId"
            .populate "metaData.tagIds"
            , (error) ->
                if error?
                    logger.error error: error, "wasn't able to get dataset"
                    return res.status(500).json error: errorHandler.format error
                else
                    if not dataset?
                        logger.error error: "dataset not found"
                        return res.status(404).json error: errorHandler.format 404

                    logger.debug dataset: dataset, "return dataset"
                    return res.json dataset

    .catch (error) ->
        return res.status(500).json error: errorHandler.format()

findOrCreateTag = (tag, dataset) ->
    return new Promise (resolve, reject) ->
        Tag.findOrCreate tag, (error, tag) ->
            reject error if error?
            dataset.metaData.tagIds.push tag._id
            resolve tag

module.exports =
    dataset: dataset
