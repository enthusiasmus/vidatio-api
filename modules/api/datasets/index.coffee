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

@apiUse SuccessDataset
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
#
#
datasetIdRoot = dataset.route "/:id"

###
@api {delete} dataset/:id/ DELETE - delete a Dataset by Id
@apiName deleteDataset
@apiGroup Dataset
@apiVersion 0.0.1

@apiDescription Delete a Dataset by Id. This doesn't really deletes the Dataset,
a deleted flag is set to true.

@apiUse SuccessDataset
###

datasetIdRoot.delete (req, res) ->
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

#userCheckRoot = user.route "/check"

###
@api {check} user/check?email&name GET - check if a username or email exists
@apiName checkUser
@apiGroup Dataset
@apiVersion 0.0.1

@apiDescription Check if the given username or email is already in the database.

@apiSuccessExample {json} Success-Response:
    HTTP/1.1 200 OK
    {
        "message": "email / name available
    }
###

#userCheckRoot.get (req, res) ->
#    for key, value of req.query
#        switch key
#            when "email", "name"
#                obj = "#{key}": value
#                User.findOne obj, (error, user) ->
#                    if error
#                        logger.error error: error, "wasn't able to find user by #{key}"
#                        error = errorHandler.format error
#                        return res.status(500).json error: error
#
#                    if not user? or user.deleted
#                        return res.status(404).json error: "not found"
#
#                    logger.debug user: user, "found user by #{key}"
#                    return res.status(200).json message: value + " not available"

module.exports =
    dataset: dataset
