"use strict"

frisby = require "frisby"

config = require "../../config"

data =
    'http://www.wien.gv.at/statistik/ogd/b17-migrationbackground-vie-subdc.csv'

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url


frisby.create('A get request with a query variable called url is requested')
    .get '/v0/import?url=' + data
    .auth "admin", "admin"
    .expectStatus 200
    .expectBodyContains('Migrationshintergrund')
.toss()
