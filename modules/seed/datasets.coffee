"use strict"

{api:logger} = require "../logger"

seedDataset1 =
    name: "Seed Dataset 1"
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

seedDataset2 =
    name: "Seed Dataset 2"
    data: [ [13.084850, 13.087736, 13.086685, 13.086181, 13.086172, 13.089662],
    [47.723955, 47.725081, 47.724881, 47.724186, 47.722308, 47.722749],
    ["Bank", "Post", "FH", "Spar", "Vidatio", "Wohnung"] ]
    metaData:
        fileType: "csv"
    options:
        type: "map"
        xColumn: 1
        yColumn: 0
        color: "#FA05AF"
        selectedDiagramName: "Karte"
        useColumnHeadersFromDataset: false

seedDatasets = [seedDataset1, seedDataset2]

    # [ ["Einnahmen", 100, 200, 300, 400], ["Ausgaben", 10, 20, 30, 40] ]
    # [ [13.084850, 13.087736, 13.086685, 13.086181, 13.086172, 13.089662], [47.723955, 47.725081, 47.724881, 47.724186, 47.722308, 47.722749], ["Bank", "Post", "FH", "Spar", "Vidatio", "Wohnung"] ]
    # [ [200, 300, 400], [500, 600, 700] ]
    # [ ["01.01.2014", "01.01.2015", "01.01.2016"], ["Idee Vidatio", "Umsetzung Vidatio", "Gewinn Vidatio"] ]

module.exports = (db, users, categories, tags) ->
    Dataset = db.model "Dataset"
    User = db.model "User"

    Dataset.find {}, (err, datasets) ->
        if datasets.length == 0
            logger.info "No datasets available in datasets collection"

            Promise.all [users, categories, tags]
            .then (result) ->
                users = result[0]
                categories = result[1]
                tags = result[2]

                if users.length is 0
                    return

                console.log "seedDatasets", seedDatasets

                for seedDataset, i in seedDatasets
                    console.log "seedDataset", seedDataset
                    # logger.info "Inserting dataset #{i % seedDatasets.length} for seed user #{i}"

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

                    console.log "Create Dataset"
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
