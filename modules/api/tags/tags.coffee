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
        message: "API.DATASET.CREATE.NAME.NOTVALID"
]

tagSchema = mongoose.Schema
    name:
        type: String
        required: "API.DATASET.CREATE.NAME.REQUIRED"
        validate: nameValidator

tagModel = db.model "Dataset", tagSchema
module.exports =
    schema: tagSchema
    model:  tagModel
