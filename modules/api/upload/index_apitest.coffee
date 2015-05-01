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

frisby.create('A post request on v0/upload retrieves the file which got passed')
    .post '/v0/upload', {
        url: "http://www.wien.gv.at/statistik/ogd/b17-migrationbackground-vie-subdc.csv"
    }
    .auth "admin", "admin"
    .expectStatus 200
    .expectBodyContains('Migrationshintergrund')
.toss()

frisby.create('A get request with a query variable called url is requested')
    .get '/v0/upload?url=http://www.wien.gv.at/statistik/ogd/b17-migrationbackground-vie-subdc.csv'
    .auth "admin", "admin"
    .expectStatus 200
    .expectBodyContains('Migrationshintergrund')
.toss()
