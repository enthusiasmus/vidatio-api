"use strict"

frisby = require "frisby"

config = require "../../config"

{model:Dataset} = require "./dataset"
{model:User} = require "../users/user"
{model:Category} = require "../categories/category"

datasetRoute = "/" + config.apiVersion + "/datasets"
userRoute = "/" + config.apiVersion + "/users"

testuser =
    name: "datasetAdmin"
    email: "dataset@admin.com"
    password: "admin"

testDataset =
    data:
        key1: "value1"
    visualizationOptions:
        option1: "option1"
    metaData:
        name: "First Dataset"
        fileType: "csv"
    published: false

promises = []

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

    User.create
        email: testuser.email
        name: testuser.name
        password: testuser.password
    .then (user) ->

        Category.find {}
        .exec (error, categories) ->
            category = categories[0]
            testDataset.metaData["categoryId"] = category._id

            frisby.create "Expect 500 on creating dataset without name"
                .post datasetRoute,
                    data:
                        key1: "value1"
                    visualizationOptions:
                        option1: "option1"
                    metaData:
                        name: ""
                        userId: user._id
                        fileType: "csv"
                        categoryId: category._id
                .auth testuser.email, testuser.password
                .expectHeaderContains "Content-Type", "json"
                .expectStatus 500
                .expectJSON {
                    error:
                        name: "ValidationError"
                        errors: [{
                            "metaData.name":
                                i18n: "API.ERROR.DATASET.CREATE.NAME.REQUIRED"
                                value: ""
                        }]
                }
            .toss()

            frisby.create "Expect a successful creation of a dataset"
                .post datasetRoute, testDataset
                .auth testuser.email, testuser.password
                .expectHeaderContains "Content-Type", "json"
                .expectStatus 200
                .after (error, res, body) ->
                    dataset = body

                    expect(dataset.metaData.name).toEqual("First Dataset")
                    expect("#{dataset.metaData.userId._id}").toEqual("#{user._id}")
                    expect(dataset.data).toEqual({ key1: "value1" })
                    expect(dataset.visualizationOptions).toEqual({ option1: "option1" })

                    frisby.create "get all datasets"
                        .get datasetRoute
                        .expectHeaderContains "Content-Type", "json"
                        .expectStatus 200
                        .after((error, res, body) ->
                            datasets = body
                            expect(datasets).toBeDefined()
                            expect(datasets).toEqual(jasmine.any(Array))
                            expect(datasets[0]).toEqual(jasmine.any(Object))

                            ###
                             This is in .after callback of "get all datasets" because it is necessary that the following test and the test
                             before executes before deleting the dataset again and therefore this nesting is needed
                            ###
                            frisby.create "get dataset by id"
                                .get datasetRoute + "/#{dataset._id}"
                                .expectHeaderContains "Content-Type", "json"
                                .expectStatus 200
                                .after((error, res, body) ->
                                    expect(body).toBeDefined()
                                    expect(body.visualizationOptions).toEqual(dataset.visualizationOptions)
                                    expect(body.data).toEqual(dataset.data)
                                    expect(body._id).toEqual(dataset._id)
                                    expect(body.metaData.name).toEqual(dataset.metaData.name)

                                    frisby.create "expect a successful deletion of a dataset"
                                        .delete "#{datasetRoute}/#{dataset._id}"
                                        .auth testuser.email, testuser.password
                                        .expectStatus 204
                                        .toss()

                                ).toss()

                        ).toss()

            .toss()

            deepCopyDataset = JSON.parse(JSON.stringify(testDataset))
            deepCopyDataset.metaData.name = "Tmp Dataset"
            deepCopyDataset.metaData.tags = ["tag1", "tag 2"]

            frisby.create "Expect a successful creation of a dataset with tags"
                .post datasetRoute, deepCopyDataset
                .auth testuser.email, testuser.password
                .expectHeaderContains "Content-Type", "json"
                .expectStatus 200
                .after((error, res, body) ->
                    dataset = body
                    expect(dataset).toBeDefined()
                    expect(dataset.visualizationOptions).toEqual(deepCopyDataset.visualizationOptions)
                    expect(dataset.data).toEqual(deepCopyDataset.data)
                    expect(dataset.metaData).toBeDefined()
                    expect(dataset.metaData.name).toEqual(deepCopyDataset.metaData.name)
                    expect(dataset.metaData.categoryId).toBeDefined()
                    expect(dataset.metaData.categoryId._id).toEqual(jasmine.any(String))
                    expect(dataset.metaData.categoryId._id).toEqual(deepCopyDataset.metaData.categoryId)
                    expect(dataset.metaData.tagIds).toBeDefined()
                    expect(dataset.metaData.tagIds).toEqual(jasmine.any(Array))
                    expect(dataset.metaData.tagIds.length).toEqual(2)

                    frisby.create "expect a successful deletion of a dataset"
                        .delete "#{datasetRoute}/#{dataset._id}"
                        .auth testuser.email, testuser.password
                        .expectStatus 204
                        .toss()
                ).toss()
