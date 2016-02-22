"use strict"

frisby = require "frisby"

config = require "../../config"

{model:Category} = require "./category"

categoryRoute = "/" + config.apiVersion + "/categories"

testCategory =
    name: "testCategory"

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

Category.create testCategory, (error, doc) ->

    frisby.create "Query categories"
        .get categoryRoute
        .expectHeaderContains "Content-Type", "json"
        .expectStatus 200
        .after (error, res, body) ->
            expect(body).toBeDefined()
            expect(body[body.length - 1]).toEqual(
                name: "testCategory"
            )

            Category.findOneAndRemove body[body.length - 1]
            .exec()
    .toss()


