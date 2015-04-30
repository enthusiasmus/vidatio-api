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

frisby.create('Ensure response has proper JSON types in specified keys')
    .post '/v0/upload', {
      url: "http://www.wien.gv.at/statistik/ogd/b17-migrationbackground-vie-subdc.csv"
    }
    .auth "admin", "admin"
    .expectStatus 200
    .expectBodyContains('Migrationshintergrund')
.toss()
