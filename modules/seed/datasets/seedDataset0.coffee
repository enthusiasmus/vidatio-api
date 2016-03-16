"use strict"

module.exports =
    name: "Seed Dataset Bar 1"
    data: [ [200, "Orange"], [300, "Banane"], [400, "Apfel"] ]
    metaData:
        fileType: "csv"
    options:
        type: "bar"
        xColumn: 1
        yColumn: 0
        color: "#FA05AF"
        useColumnHeadersFromDataset: false
