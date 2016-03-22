"use strict"

frisby = require "frisby"

config = require "../../config"

dataCSV = encodeURIComponent("http://data.ooe.gv.at/files/cms/Mediendateien/OGD/ogd_abtStat/Wahl_LT_09_OGD.csv")
dataSHP = encodeURIComponent("http://data.stadt-salzburg.at/geodaten/wfs?service=WFS&version=1.1.0&request=GetFeature&srsName=EPSG:4326&outputFormat=shape-zip&typeName=ogdsbg:behindertenstellplatz")

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

# describe "Forward with CSV", ->
#     frisby.create('A get request with a query variable called url is requested')
#         .get '/v0/forward?url=' + dataCSV
#         .expectStatus 200
#         .after (error, res, body) ->
#             expect(body.fileType).toEqual("csv")
#             expect(body.body).toMatch("Gemeindenummer;Name;Wahlberechtigte;")
#         .toss()

# describe "Forward with SHP", ->
#     frisby.create('A get request with a query variable called url is requested')
#         .get '/v0/forward?url=' + dataSHP
#         .expectStatus 200
#         .after (error, res, body) ->
#             expect(body.fileType).toEqual("zip")
#             expect(body.body.type).toEqual("Buffer")
#         .toss()


