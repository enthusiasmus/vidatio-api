"use strict"

frisby = require "frisby"

config = require "../../config"
{model:Dataset} = require "./dataset"

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

frisby.create "Expect 500 on creating dataset without name"
    .post "/v0/dataset",
        name: ""
        userId: "123abcd12312312312312312"
        data:
            key1: "value1"
        options:
            option1: "option1"
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
        .post "/v0/dataset",
            name: "First Dataset"
            userId: "123abcd12312312312312312"
            data:
                key1: "value1"
            options:
                option1: "option1"
        .expectHeaderContains "Content-Type", "json"
        .expectStatus 200
        .after (error, res, body) ->
            dataset = body

            expect(dataset.name).toEqual("First Dataset")
            expect(dataset.userId).toEqual("123abcd12312312312312312")
            expect(dataset.data).toEqual({ key1: "value1" })
            expect(dataset.options).toEqual({ option1: "option1" })
            expect(dataset.deleted).not.toBeTruthy()

#        frisby.create "user should not get successfully deleted because wrong authentication"
#            .delete "/v0/user/#{user._id}"
#            .auth user.email, "admin2"
#            .expectStatus 401
#            .toss()

            frisby.create "dataset should get successfully deleted"
                .delete "/v0/dataset/#{dataset._id}"
#                .auth user.email, "admin"
                .expectHeaderContains "Content-Type", "json"
                .expectStatus 200
                .expectJSON {
                    message: "successfully deleted dataset"
                }
                .toss()

        .toss()
