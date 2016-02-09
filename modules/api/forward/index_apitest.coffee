"use strict"

frisby = require "frisby"

config = require "../../config"

dataCSV = 'http://data.ooe.gv.at/files/cms/Mediendateien/OGD/ogd_abtStat/Wahl_LT_09_OGD.csv'
dataSHP = 'http://data.wien.gv.at/daten/geo?service=WFS&request=GetFeature&version=1.1.0&typeName=ogdwien:KINDERGARTENOGD&srsName=EPSG:4326&outputFormat=shape-zip'

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

describe "Forward with CSV", ->
    frisby.create('A get request with a query variable called url is requested')
        .get '/v0/forward?url=' + dataCSV
        .expectStatus(200)
        .expectBodyContains('Gemeindenummer;Name;Wahlberechtigte')
        .toss()

describe "Forward with SHP", ->
    frisby.create('A get request with a query variable called url is requested')
        .get '/v0/forward?url=' + dataSHP
        .expectStatus(200)
        .toss()
