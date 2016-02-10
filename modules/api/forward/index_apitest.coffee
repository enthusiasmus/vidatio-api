"use strict"

frisby = require "frisby"

config = require "../../config"

dataCSV = 'http://data.ooe.gv.at/files/cms/Mediendateien/OGD/ogd_abtStat/Wahl_LT_09_OGD.csv'
dataSHP = 'http://biogeo.ucdavis.edu/data/diva/pop/BHR_pop.zip'

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
        .expectStatus 200
        .after (error, res, body) ->

            expect(body.fileType).toEqual("csv")
            expect(body.body).toMatch("Gemeindenummer;Name;Wahlberechtigte;")

        .toss()

describe "Forward with SHP", ->
    frisby.create('A get request with a query variable called url is requested')
        .get '/v0/forward?url=' + dataSHP
        .expectStatus 200
        .after (error, res, body) ->

            expect(body.fileType).toEqual("zip")
            expect(body.body.type).toEqual("Buffer")

        .toss()


