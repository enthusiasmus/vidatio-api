"use strict"

frisby = require "frisby"

config = require "./config"


frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

frisby.create "Check CORS middleware to return Access-Control-Allow Headers"
    .options "/"
    .expectStatus 200
    .expectHeader "Access-Control-Allow-Origin", "*"
    .expectHeader "Access-Control-Allow-Headers", "Origin, X-Requested-With, " +
        "Content-Type, Accept, Authorization, X-HTTP-Method-Override"
    .expectHeader "Access-Control-ALlow-Methods",
        "GET, POST, PUT, DELETE, OPTIONS"
    .toss()
