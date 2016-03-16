"use strict"

module.exports =
    name: "Seed Dataset Bar 2"
    data: [["Stimmen", "Kandidat"]
    [100, "Rubio"],
    [200, "Sanders"],
    [300, "Trump"],
    [400, "Clinton"]]
    metaData:
        fileType: "csv"
    options:
        type: "bar"
        xColumn: 1
        yColumn: 0
        color: "#0505AF"
        useColumnHeadersFromDataset: true
