"use strict"

frisby = require "frisby"

config = require "../../config"

{model:Tag} = require "./tag"

tagRoute = "/" + config.apiVersion + "/tags"

testTag =
    name: "testTag"

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

Tag.create testTag, (error, doc) ->

    frisby.create "Query tags"
        .get tagRoute
        .expectHeaderContains "Content-Type", "json"
        .expectStatus 200
        .after (error, res, body) ->
            expect(body).toBeDefined()
            testTagIndex = -1
            for element, index in body
                if element.name = testTag.name
                    testTagIndex = index

            expect(body[testTagIndex]._id).toBeDefined()
            expect(body[testTagIndex].name).toBeDefined()
            expect(body[testTagIndex].name).toEqual("testTag")

            Tag.findOneAndRemove
                name: "testTag"
            .exec()
    .toss()


