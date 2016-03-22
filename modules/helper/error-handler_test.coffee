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
        expect(errorHandler.format(MONGO_ERROR)).toEqual jasmine.any Object
        expect(errorHandler.format(MONGO_ERROR)).toEqual {
            name: "MongoError"
            errors: [
                {
                    mongo:
                        i18n: "API.MONGO.ERROR"
                        value: "undefined"
                }
            ]
        }

    it "should correctly format a validation error for client-side parsing", ->
        expect(errorHandler.format(VALIDATION_ERROR)).toEqual jasmine.any Object
        expect(errorHandler.format(VALIDATION_ERROR)).toEqual {
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
