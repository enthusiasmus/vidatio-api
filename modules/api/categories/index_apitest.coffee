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
            categoryNames = []
            for category in body
                categoryNames.push category.name

            expect(categoryNames).toContain(testCategory.name)

            Category.findOneAndRemove
                name: testCategory.name
            .exec()
    .toss()


