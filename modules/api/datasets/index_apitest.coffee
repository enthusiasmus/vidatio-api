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

testDataset =
    name: "First Dataset"
    data:
        key1: "value1"
    options:
        option1: "option1"

tagTestDataset =
    name: "Second Dataset"
    data:
        key1: "value1"
    options:
        option1: "option1"
    metaData:
        category: "test-category"
        tags: ["tag1", "tag2"]

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

            Dataset.remove
                name: "First Dataset"
            , ->
                frisby.create "Expect a successful creation of a dataset"
                    .post datasetRoute, testDataset
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

                        frisby.create "get all datasets"
                            .get datasetRoute
                            .expectHeaderContains "Content-Type", "json"
                            .expectStatus 200
                            .after((error, res, body) ->
                                datasets = body
                                expect(datasets).toBeDefined()
                                expect(datasets).toEqual(jasmine.any(Array))
                                expect(datasets[0]).toEqual(jasmine.any(Object))
                            ).toss()

                        frisby.create "get dataset by id"
                            .get datasetRoute + "/#{dataset._id}"
                            .expectHeaderContains "Content-Type", "json"
                            .expectStatus 200
                            .after((error, res, body) ->
                                expect(body).toBeDefined()
                                expect(body.options).toEqual(dataset.options)
                                expect(body.data).toEqual(dataset.data)
                                expect(body._id).toEqual(dataset._id)
                                expect(body.name).toEqual(dataset.name)
                            ).toss()

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

            Dataset.remove
                name: "Second Dataset"
            , ->
                frisby.create "Expect a successful creation of a dataset with tags"
                    .post datasetRoute, tagTestDataset
                    .auth testuser.email, testuser.password
                    .expectHeaderContains "Content-Type", "json"
                    .expectStatus 200
                    .after((error, res, body) ->
                        dataset = body
                        expect(dataset).toBeDefined()
                        expect(dataset.options).toEqual(tagTestDataset.options)
                        expect(dataset.data).toEqual(tagTestDataset.data)
                        expect(dataset.name).toEqual(tagTestDataset.name)

                        expect(dataset.metaData).toBeDefined()
                        expect(dataset.metaData.category).toBeDefined()
                        expect(dataset.metaData.category).toEqual(jasmine.any(String))
                        expect(dataset.metaData.tags).toBeDefined()
                        expect(dataset.metaData.tags).toEqual(jasmine.any(Array))
                        expect(dataset.metaData.tags.length).toEqual(2)

                    ).toss()

        .toss()

