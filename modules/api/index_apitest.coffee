"use strict"

frisby = require "frisby"

jasmine = require "jasmine-node"

config = require "../config"

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

frisby.create "Expect 404 on not defined base route"
    .get "/asdf"
    .expectStatus 404
    .expectHeader "Access-Control-Allow-Origin", "*"
    .expectHeader "Access-Control-Allow-Headers", "Origin, X-Requested-With, " +
        "Content-Type, Accept, Authorization, X-HTTP-Method-Override"
    .expectHeader "Access-Control-ALlow-Methods",
        "GET, POST, PUT, DELETE, OPTIONS"
    .expectJSON error: "not found"
    .toss()

frisby.create "Expect 404 on not defined /v0/api route"
    .get "/v0/asdf"
    .expectStatus 404
    .expectHeader "Access-Control-Allow-Origin", "*"
    .expectHeader "Access-Control-Allow-Headers", "Origin, X-Requested-With, " +
        "Content-Type, Accept, Authorization, X-HTTP-Method-Override"
    .expectHeader "Access-Control-ALlow-Methods",
        "GET, POST, PUT, DELETE, OPTIONS"
    .expectJSON error: "not found"
    .toss()



penguinLogger =
    name: "penguins"
    level: "TRACE"
    streams: [{
        type: "rotating-file"
        path: "#{ config.dirs.log }/penguins.log"
        period: "1d"
        count: 365
        level: "TRACE"
    }]


apiLogger =
    name: "api"
    level: "TRACE"
    streams: [{
        type: "rotating-file"
        path: "#{ config.dirs.log }/api.log"
        period: "1d"
        count: 365
        level: "TRACE"
    }]

expectedLoggers = [ penguinLogger, apiLogger ]


frisby.create "Expect available loggers on /v0/logs"
    .get "/v0/logs"
    .expectStatus 200
    .expectJSONTypes "*",
        name: String
        level: String
        streams: ( streams ) ->
            for stream in streams
                expect( stream.type ).toEqual jasmine.any String
                expect( stream.path ).toEqual jasmine.any String
                expect( stream.period ).toEqual jasmine.any String
                expect( stream.count ).toEqual jasmine.any Number
                expect( stream.level ).toEqual jasmine.any String
            return
    .expectJSON expectedLoggers
    .toss()


frisby.create "Expect api logger on /v0/logs/api"
    .get "/v0/logs/api"
    .expectStatus 200
    .expectJSONTypes
        fields:
            name: String
    .expectJSON
        fields:
            name: "api"
    .toss()


frisby.create "Expect penguins logger on /v0/logs/penguins"
    .get "/v0/logs/penguins"
    .expectStatus 200
    .expectJSONTypes
        fields:
            name: String
    .expectJSON
        fields:
            name: "penguins"
    .toss()

