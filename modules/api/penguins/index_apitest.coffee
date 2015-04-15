"use strict"

frisby = require "frisby"

config = require "../../config"

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
    .expectJSON
        error: "not found"
    .toss()

frisby.create "Expect 404 on not defined /v0/api route"
    .get "/v0/asdf"
    .expectStatus 404
    .expectHeader "Access-Control-Allow-Origin", "*"
    .expectHeader "Access-Control-Allow-Headers", "Origin, X-Requested-With, " +
        "Content-Type, Accept, Authorization, X-HTTP-Method-Override"
    .expectHeader "Access-Control-ALlow-Methods",
        "GET, POST, PUT, DELETE, OPTIONS"
    .expectJSON
        error: "not found"
    .toss()
