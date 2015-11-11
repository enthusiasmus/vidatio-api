"use strict"

frisby = require "frisby"

config = require "../../config"

{model:Dataset} = require "./dataset"
{model:User} = require "../users/user"

datasetRoute = "/" + config.apiVersion + "/datasets"
userRoute = "/" + config.apiVersion + "/users"

testuser =
    name: "datasetAdmin"
    email: "dataset@admin.com"
    password: "admin"

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

User.findOneAndRemove {
    "name": testuser.name
}, (error, doc, result) ->

    frisby.create "Create a user for authentication"
        .post userRoute,
            email: testuser.email
            name: testuser.name
            password: testuser.password
        .after (error, res, body) ->
            user = body

            frisby.create "Expect 500 on creating dataset without name"
                .post datasetRoute,
                    name: ""
                    userId: user._id
                    data:
                        key1: "value1"
                    options:
                        option1: "option1"
                .auth testuser.email, testuser.password
                .expectHeaderContains "Content-Type", "json"
                .expectStatus 500
                .expectJSON {
                    error:
                        name: "ValidationError"
                        errors:
                            name:
                                i18n: "API.DATASET.CREATE.NAME.REQUIRED"
                                value: ""
                }
                .toss()

            Dataset.remove {}, ->
                frisby.create "Expect a successful creation of a dataset"
                    .post datasetRoute,
                        name: "First Dataset"
                        userId: user._id
                        data:
                            key1: "value1"
                        options:
                            option1: "option1"
                    .auth testuser.email, testuser.password
                    .expectHeaderContains "Content-Type", "json"
                    .expectStatus 200
                    .after (error, res, body) ->
                        dataset = body

                        expect(dataset.name).toEqual("First Dataset")
                        expect(dataset.userId).toEqual(user._id)
                        expect(dataset.data).toEqual({ key1: "value1" })
                        expect(dataset.options).toEqual({ option1: "option1" })
                        expect(dataset.deleted).not.toBeTruthy()

                        frisby.create "dataset should get successfully deleted"
                            .delete datasetRoute + "/#{dataset._id}"
                            .auth testuser.email, testuser.password
                            .expectHeaderContains "Content-Type", "json"
                            .expectStatus 200
                            .expectJSON {
                                message: "successfully deleted dataset"
                            }
                            .toss()

                    .toss()







        .toss()


