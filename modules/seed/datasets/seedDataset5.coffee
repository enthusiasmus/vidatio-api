"use strict"

module.exports =
    data: [ ["Datum", "Kurs"],
    ["01.01.2014", 800],
    ["13.07.2014", 950],
    ["01.01.2015", 1200],
    ["10.11.2015", 1150],
    ["01.01.2016", 1100],
    ["24.08.2016", 1300],
    ["01.01.2017", 1500],
    ["03.05.2017", 1450],
    ["01.01.2018", 1600],
    ["15.03.2018", 1700] ]
    metaData:
        name: "Seed Dataset Timeseries"
        fileType: "csv"
    visualizationOptions:
        type: "timeseries"
        xColumn: 0
        yColumn: 1
        color: "#05AA05"
        useColumnHeadersFromDataset: true
