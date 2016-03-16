"use strict"

{api:logger} = require "../logger"

seedDataset0 = require "./datasets/seedDataset0"
seedDataset1 = require "./datasets/seedDataset1"
seedDataset2 = require "./datasets/seedDataset2"
seedDataset3 = require "./datasets/seedDataset3"
seedDataset4 = require "./datasets/seedDataset4"
seedDataset5 = require "./datasets/seedDataset5"

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
