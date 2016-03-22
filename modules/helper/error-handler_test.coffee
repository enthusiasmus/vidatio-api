"use strict"

errorHandler = require "./error-handler"

# coffeelint: disable=max_line_length
VALIDATION_ERROR =
    'stack': 'Error\n    at MongooseError.ValidationError (/home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/error/validation.js:22:16)\n    at model.Document.invalidate (/home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/document.js:1260:32)\n    at /home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/document.js:1135:16\n    at validate (/home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/schematype.js:662:7)\n    at /home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/schematype.js:693:9\n    at Array.forEach (native)\n    at SchemaString.SchemaType.doValidate (/home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/schematype.js:667:19)\n    at /home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/document.js:1133:9\n    at process._tickCallback (node.js:355:11)'
    'message': 'User validation failed'
    'name': 'ValidationError'
    'errors':
        'email':
            'properties':
                'type': 'required'
                'message': 'API.USER.REGISTER.EMAIL.REQUIRED'
                'path': 'email'
                'value': ''
            'stack': 'Error\n    at MongooseError.ValidatorError (/home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/error/validator.js:25:16)\n    at validate (/home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/schematype.js:661:13)\n    at /home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/schematype.js:693:9\n    at Array.forEach (native)\n    at SchemaString.SchemaType.doValidate (/home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/schematype.js:667:19)\n    at /home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/document.js:1133:9\n    at process._tickCallback (node.js:355:11)'
            'message': 'API.USER.REGISTER.EMAIL.REQUIRED'
            'name': 'ValidatorError'
            'kind': 'required'
            'path': 'email'
            'value': ''

        'name':
            'properties':
                'type': 'required'
                'message': 'API.USER.REGISTER.NAME.REQUIRED'
                'path': 'name'
            'stack': 'Error\n    at MongooseError.ValidatorError (/home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/error/validator.js:25:16)\n    at validate (/home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/schematype.js:661:13)\n    at /home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/schematype.js:693:9\n    at Array.forEach (native)\n    at SchemaString.SchemaType.doValidate (/home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/schematype.js:667:19)\n    at /home/gbeschbacher/Documents/api-vidatio/node_modules/mongoose/lib/document.js:1133:9\n    at process._tickCallback (node.js:355:11)'
            'message': 'API.USER.REGISTER.NAME.REQUIRED'
            'name': 'ValidatorError'
            'kind': 'required'
            'path': 'name'

MONGO_ERROR =
    'code': 11000
    'index': 0
    'name': 'MongoError'
    'errmsg': 'insertDocument :: caused by :: 11000 E11000 duplicate key error index: vidatio_test.users.$email_1  dup key: { : "admin@admin.com" }'
    'op':
        'hash': '4c27c1ae2785e8dcf26b623bdda77b8e6c432aef'
        'salt': '1387744742222'
        'name': 'admin'
        'email': 'admin@admin.com'
        '_id': '563b4e7440287a523c986141'
        'admin': false
        'deleted': false
        '__v': 0
# coffeelint: enable=max_line_length

describe "Error-Handler", ->
    it "should be defined", ->
        expect(errorHandler).toBeDefined()

    it "should have a format function", ->
        expect(errorHandler.format).toBeDefined()

    it "should correctly format a mongo error for client-side parsing", ->
        error = errorHandler.format(MONGO_ERROR)
        expect(error).toEqual jasmine.any Object
        expect(error).toEqual {
            name: "MongoError"
            errors: [
                {
                    mongo:
                        i18n: "API.ERROR.MONGO"
                        value: "undefined"
                }
            ]
        }

    it "should correctly format a validation error for client-side parsing", ->
        error = errorHandler.format(VALIDATION_ERROR)
        expect(error).toEqual jasmine.any Object
        expect(error).toEqual {
            name: "ValidationError"
            errors:[
                {
                    email:
                        i18n: "API.USER.REGISTER.EMAIL.REQUIRED"
                        value: ""
                },
                {
                    name:
                        i18n: "API.USER.REGISTER.NAME.REQUIRED"
                        value: ""
                }
            ]
        }

    it "should correctly format a 404 not found error for client-side parsing", ->
        error = errorHandler.format(404)
        expect(error).toEqual jasmine.any Object
        expect(error).toEqual {
            name: "NotFound",
            errors: [
                {
                    "not.found":
                        i18n: "API.ERROR.NOTFOUND",
                        value: "404"
                }
            ]
        }

    it "should correctly format an unknown error for client-side parsing", ->
        error = errorHandler.format()
        expect(error).toEqual jasmine.any Object
        expect(error).toEqual {
            name: "Unknown",
            errors: [
                {
                    "unknown":
                        i18n: "API.ERROR.UNKNOWN",
                        value: "An unknown error occured"
                }
            ]
        }

    it "should correctly format a parameter error for client-side parsing", ->
        error = errorHandler.format
            name: "ParameterError"
            value: "blabla"

        expect(error).toEqual jasmine.any Object
        expect(error).toEqual {
            name: "ParameterError",
            errors: [
                {
                    "parameter":
                        i18n: "API.ERROR.PARAMETER",
                        value: "blabla"
                }
            ]
        }

    it "should correctly format a header error for client-side parsing", ->
        error = errorHandler.format
            name: "HeaderError"
            value: "blabla"

        expect(error).toEqual jasmine.any Object
        expect(error).toEqual {
            name: "HeaderError",
            errors: [
                {
                    "header":
                        i18n: "API.ERROR.HEADER",
                        value: "blabla"
                }
            ]
        }
