"use strict"

{api:logger} = require "../logger"

seedDataset0 =
    name: "Seed Dataset Bar 1"
    data: [ [200, "Orange"], [300, "Banane"], [400, "Apfel"] ]
    metaData:
        fileType: "csv"
    options:
        type: "bar"
        xColumn: 1
        yColumn: 0
        color: "#FA05AF"
        selectedDiagramName: "Balkendiagramm"
        useColumnHeadersFromDataset: false

seedDataset1 =
    name: "Seed Dataset Map"
    data: [[47.723955, 13.084850, "Bank"],
    [47.725081, 13.087736, "Post"],
    [47.724881, 13.086685, "FH"],
    [47.724186, 13.086181, "Spar"],
    [47.722308, 13.086172, "Vidatio"],
    [47.722749, 13.089662, "Wohnung"]]
    metaData:
        fileType: "csv"
    options:
        type: "map"
        xColumn: 1
        yColumn: 0
        color: null
        selectedDiagramName: "Karte"
        useColumnHeadersFromDataset: false

seedDataset2 =
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
        selectedDiagramName: "Balkendiagramm"
        useColumnHeadersFromDataset: true

seedDataset3 =
    name: "Seed Dataset Scatter"
    data: [ [200, 300],
    [500, 600],
    [120, 100],
    [170, 250],
    [280, 400],
    [460, 370] ]
    metaData:
        fileType: "csv"
    options:
        type: "scatter"
        xColumn: 0
        yColumn: 1
        color: "#AA0505"
        selectedDiagramName: "Streudiagramm"
        useColumnHeadersFromDataset: false

seedDataset4 =
    name: "Seed Dataset Parallel"
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
        fileType: "csv"
    options:
        type: "parallel"
        xColumn: 0
        yColumn: 1
        color: "#42BCF0"
        selectedDiagramName: "Parallele Koordinaten"
        useColumnHeadersFromDataset: true

seedDataset5 =
    name: "Seed Dataset Timeseries"
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
        fileType: "csv"
    options:
        type: "timeseries"
        xColumn: 0
        yColumn: 1
        color: "#05AA05"
        selectedDiagramName: "Zeitlicher Verlauf"
        useColumnHeadersFromDataset: true

seedDatasets = [seedDataset0, seedDataset1, seedDataset2, seedDataset3, seedDataset4, seedDataset5]

module.exports = (db, users, categories, tags) ->
    Dataset = db.model "Dataset"
    User = db.model "User"

    Dataset.find {}, (err, datasets) ->
        if datasets.length == 0
            logger.info  "No datasets available in datasets collection"
            console.log  "No datasets available in datasets collection"

            Promise.all [users, categories, tags]
            .then (result) ->
                users = result[0]
                categories = result[1]
                tags = result[2]

                if users.length is 0
                    return

                for seedDataset, i in seedDatasets
                    logger.info "Inserting dataset #{i} for seed user #{i % users.length}"
                    console.log  "Inserting dataset #{i} for seed user #{i % users.length}"

                    categoryIndex = Math.floor(Math.random() * categories.length)

                    # create 0 to 3 tags for each dataset
                    numOfTags = Math.floor(Math.random() * 4)
                    datasetTags = []
                    j = 0
                    while j < numOfTags
                        randomTagIndex = Math.floor(Math.random() * tags.length)
                        tagID = tags[randomTagIndex % tags.length].upserted[0]._id
                        datasetTags.push tagID
                        j++

                    Dataset.create
                        name: seedDataset.name
                        userId: users[i % users.length]._id
                        data: seedDataset.data
                        metaData:
                            category: categories[categoryIndex].upserted[0]._id
                            tags: datasetTags
                            fileType: seedDataset.metaData.fileType
                        options: seedDataset.options
                    , (error, dataset) ->
                        if error
                            logger.error "seeding datasets"
                            logger.debug
                                error: error
                                dataset: dataset
                        else
                            logger.info "seeded dataset"
                            logger.debug
                                dataset: dataset
        else
            console.log "No need to seed datasets"
