"use strict"

module.exports =
    data: [ ["Ware", "Wert"],
    ["Rot", 800],
    ["Grün", 950],
    ["Blau", 1200],
    ["Rot", 1150],
    ["Blau", 1100],
    ["Gelb", 1300],
    ["Blau", 1500],
    ["Grün", 1450],
    ["Rot", 1600],
    ["Blau", 1700] ]
    metaData:
        name: "Seed Dataset Parallel"
        fileType: "csv"
    visualizationOptions:
        type: "parallel"
        xColumn: 0
        yColumn: 1
        color: "#42BCF0"
        useColumnHeadersFromDataset: true
