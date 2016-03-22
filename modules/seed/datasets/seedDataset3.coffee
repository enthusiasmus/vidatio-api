"use strict"

module.exports =
    data: [ [200, 300],
    [500, 600],
    [120, 100],
    [170, 250],
    [280, 400],
    [460, 370] ]
    metaData:
        name: "Seed Dataset Scatter"
        fileType: "csv"
    options:
        type: "scatter"
        xColumn: 0
        yColumn: 1
        color: "#AA0505"
        useColumnHeadersFromDataset: false
