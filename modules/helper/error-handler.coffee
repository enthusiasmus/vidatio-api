"use strict"
class ErrorHandler
    format: (error = 0) ->

        unless typeof error is "object"
            switch error
                when 404
                    error =
                        name: "NotFound"
                        code: error
                else
                    error =
                        name: "Unknown"

        _formatedError = {}
        _formatedError.name = error.name
        _formatedError.errors = []

        switch error.name
            when "ValidationError"
                for key, value of error.errors
                    _formatedError.errors.push "#{key}":
                        i18n: value.message
                        value: value.value || ""

            when "MongoError"
                _formatedError.errors.push "mongo":
                    i18n: "API.ERROR.MONGO"
                    value: "undefined"

            when "ParameterError"
                _formatedError.errors.push "parameter":
                    i18n: "API.ERROR.PARAMETER"
                    value: "#{error.value}"

            when "HeaderError"
                _formatedError.errors.push "header":
                    i18n: "API.ERROR.HEADER"
                    value: "#{error.value}"

            when "NotFound"
                _formatedError.errors.push "not.found":
                    i18n: "API.ERROR.NOTFOUND"
                    value: "#{error.code}"

            when "CastError"
                _formatedError.errors.push "cast":
                    i18n: "API.ERROR.CAST"
                    value: "#{error.value} doesn't match datatype #{error.kind}"

            when "Unknown"
                _formatedError.errors.push "unknown":
                    i18n: "API.ERROR.UNKNOWN"
                    value: "An unknown error occured"

        return _formatedError

module.exports = new ErrorHandler


###
@apiDefine ErrorHandlerValidation
@apiError {String} name Contains the name of the error
@apiError {Array} errors Contains all errors as an array of error-objects
@apiErrorExample {json} Validation-error response:
    HTTP/1.1 500 Internal Server Error
    {
        name: "ValidationError",
        errors: [
            {
                "email": {
                    i18n: "API.USER.REGISTER.EMAIL.REQUIRED",
                    value: ""
                }
            },
            {
                "metaData.name":
                    i18n: "API.DATASET.CREATE.NAME.REQUIRED",
                    value: ""
            }
        ]
    }
###

###
@apiDefine ErrorHandlerMongo
@apiError {String} name Contains the name of the error
@apiError {Array} errors Contains all errors as an array of error-objects
@apiErrorExample {json} MongoDb-error response:
    HTTP/1.1 500 Internal Server Error
    {
        name: "MongoError",
        errors: [
            {
                mongo:
                    i18n: "API.MONGO.ERROR",
                    value: "undefined"
            }
        ]
    }
###

###
@apiDefine ErrorHandler404
@apiError {String} name Contains the name of the error
@apiError {Array} errors Contains all errors as an array of error-objects
@apiErrorExample {json} Not found response:
    HTTP/1.1 404 Not Found
    {
        name: "NotFound",
        errors: [
            {
                not.found:
                    i18n: "API.NOT-FOUND",
                    value: "404"
            }
        ]
    }
###

###
@apiDefine ErrorHandlerCheckProperties
@apiError {String} name Contains the name of the error
@apiError {Array} errors Contains all errors as an array of error-objects
@apiErrorExample {json} Parameter error response:
    HTTP/1.1 500 Not Found
    {
        name: "ParameterError",
        errors: [
            {
                parameter:
                    i18n: "API.PARAMETER.ERROR",
                    value: "To save a dataset the following keys on body must be present: data, visualizationOptions and metaData"
            }
        ]
    }
###

###
@apiDefine ErrorHandlerPromises
@apiError {String} name Contains the name of the error
@apiError {Array} errors Contains all errors as an array of error-objects
@apiErrorExample {json} Unknown error response:
    HTTP/1.1 500 Not Found
    {
        name: "Unknown",
        errors: [
            {
                "unknown":
                    i18n: "API.ERROR.UNKNOWN",
                    value: "An unknown error occured"
            }
        ]
    }
###

###
@apiDefine ErrorHandlerHeader
@apiError {String} name Contains the name of the error
@apiError {Array} errors Contains all errors as an array of error-objects
@apiErrorExample {json} Header error response:
    HTTP/1.1 500 Not Found
    {
        name: "HeaderError",
        errors: [
            {
                "header":
                    i18n: "API.ERROR.HEADER.UNKNOWN",
                    value: "An unknown error occured"
            }
        ]
    }
###
