"use strict"

module.exports =
    data: [["Stimmen", "Kandidat"]
    [100, "Rubio"],
    [200, "Sanders"],
    [300, "Trump"],
    [400, "Clinton"]]
    metaData:
        name: "Seed Dataset Bar 2"
        fileType: "csv"
    visualizationOptions:
        type: "bar"
        xColumn: 1
        yColumn: 0
        color: "#0505AF"
        useColumnHeadersFromDataset: true
