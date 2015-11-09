"use strict"

frisby = require "frisby"

config = require "../../config"

data = 'http://data.ooe.gv.at/files/cms/Mediendateien/OGD/ogd_abtStat/Wahl_LT_09_OGD.csv'

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

xdescribe "Import", ->
    frisby.create('A get request with a query variable called url is requested')
        .get '/v0/import?url=' + data
        .expectStatus(200)
        .expectBodyContains('Gemeindenummer;Name;Wahlberechtigte')
        .toss()
