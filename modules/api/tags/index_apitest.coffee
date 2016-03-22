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
            expect(body[body.length - 1]._id).toBeDefined()
            expect(body[body.length - 1].name).toBeDefined()
            expect(body[body.length - 1]).toEqual jasmine.any Object

            Tag.findOneAndRemove body[body.length - 1]
            .exec()
    .toss()


