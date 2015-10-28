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

frisby.create "Expect 500 on registering user without email"
    .post "/user",
        email: ""
        password: "admin"
    , json: true
    .expectHeaderContains("Content-Type", "json")
    .expectStatus(500)
    .toss()

frisby.create "Expect json on registering user without email"
    .post "/user",
        email: "admin"
        password: "admin"
    , json: true
    .expectHeaderContains("Content-Type", "json")
    .expectJSONTypes "args",
        _id: String,
        email: String
    .toss()
