"use strict"

frisby = require "frisby"

config = require "../../config"
{model:Dataset} = require "./dataset"

datasetRoute = "/" + config.apiVersion + "/datasets"
userRoute = "/" + config.apiVersion + "/users"

# frisby.globalSetup
#     request:
#         body: undefined
#         headers:
#             "Accept": "application/json"
#         inspectOnFailure: true
#         json: true
#         baseUri: config.url

# testuser =
#     name: "datasetAdmin"
#     email: "dataset@admin.com"
#     password: "admin"

# frisby.create "Expect a successful registration of a user"
#     .post userRoute,
#         email: testuser.email
#         name: testuser.name
#         password: testuser.password
#     .expectHeaderContains "Content-Type", "json"
#     .expectStatus 200
#     .after (error, res, body) ->
#         user = body

#     frisby.create "Expect 500 on creating dataset without name"
#         .auth testuser.email, testuser.password
#         .post datasetRoute,
#             name: ""
#             userId: user._id
#             data:
#                 key1: "value1"
#             options:
#                 option1: "option1"
#         .expectHeaderContains "Content-Type", "json"
#         .expectStatus 500
#         .expectJSON {
#             error:
#                 name: "ValidationError"
#                 errors:
#                     name:
#                         i18n: "API.DATASET.CREATE.NAME.REQUIRED"
#                         value: ""
#         }
#         .toss()

# Dataset.remove {}, ->
#     frisby.create "Expect a successful creation of a dataset"
#         .auth testuser.email, testuser.password
#         .post datasetRoute,
#             name: "First Dataset"
#             userId: user._id
#             data:
#                 key1: "value1"
#             options:
#                 option1: "option1"
#         .expectHeaderContains "Content-Type", "json"
#         .expectStatus 200
#         .after (error, res, body) ->
#             dataset = body

#             expect(dataset.name).toEqual("First Dataset")
#             expect(dataset.userId).toEqual(user._id)
#             expect(dataset.data).toEqual({ key1: "value1" })
#             expect(dataset.options).toEqual({ option1: "option1" })
#             expect(dataset.deleted).not.toBeTruthy()

#             frisby.create "dataset should get successfully deleted"
#                 .delete datasetRoute + "/#{dataset._id}"
#                 .auth testuser.email, testuser.password
#                 .expectHeaderContains "Content-Type", "json"
#                 .expectStatus 200
#                 .expectJSON {
#                     message: "successfully deleted dataset"
#                 }
#                 .toss()

#         .toss()
