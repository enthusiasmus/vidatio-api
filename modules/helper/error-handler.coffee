"use strict"

###
# This Class formats ValidationError- and MongoError objects for client-side handling
# {
#     name: "ValidationError"
#     errors: {
#         email: {
#             i18n: "NOT.VALID.ANYTHING"
#             value: "§$"
#         }
#         name: {
#             i18n: "NOT.VALID.ANYTHING"
#             value: undefined
#         }
#     }
# }
###

class ErrorHandler
    format: (error) ->
        _formatedError = {}
        _formatedError.name = error.name
        _formatedError.errors = {}

        switch error.name
            when "ValidationError"
                for key, value of error.errors
                    _formatedError.errors["#{key}"] = {}
                    _formatedError.errors["#{key}"].i18n = value.message
                    _formatedError.errors["#{key}"].value = value.value
                    unless _formatedError.errors["#{key}"].value?
                        _formatedError.errors["#{key}"].value = ""

            when "MongoError"
                _formatedError.errors.mongo = {}
                _formatedError.errors.mongo.i18n = "API.MONGO.ERROR"
                _formatedError.errors.mongo.value = "undefined"

        return _formatedError


module.exports = new ErrorHandler
