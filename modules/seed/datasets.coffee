"use strict"

seedDatasets = [
    [ [200, 300, 400], ["Orange", "Banane", "Apfel"] ]
    [ ["Einnahmen", 100, 200, 300, 400], ["Ausgaben", 10, 20, 30, 40] ]
    [ [13.084850, 13.087736, 13.086685, 13.086181, 13.086172, 13.089662], [47.723955, 47.725081, 47.724881, 47.724186, 47.722308, 47.722749], ["Bank", "Post", "FH", "Spar", "Vidatio", "Wohnung"] ]
    [ [200, 300, 400], [500, 600, 700] ]
    [ ["01.01.2014", "01.01.2015", "01.01.2016"], ["Idee Vidatio", "Umsetzung Vidatio", "Gewinn Vidatio"] ]
]

module.exports =  (db, users, categories, tags) ->
    Dataset = db.model "Dataset"
    User = db.model "User"

    Dataset.find {}, (err, datasets) ->
        if datasets.length == 0
            console.log "No datasets available in datasets collection"

            Promise.all [users, categories, tags]
            .then (result) ->
                users = result[0]
                categories = result[1]
                tags = result[2]

                if users.length is 0
                    return

                for user, i in users
                    console.log "Inserting dataset #{i % seedDatasets.length} for seed user #{i}"

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
                        name: "Dataset from #{user.name}"
                        userId: user._id
                        data: seedDatasets[i % seedDatasets.length]
                        metaData:
                            category: categories[categoryIndex].upserted[0]._id
                            tags: datasetTags
                    , (error, dataset) ->
                        return

        else
            console.log "No need to seed datasets"
