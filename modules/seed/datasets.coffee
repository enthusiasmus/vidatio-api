"use strict"

{api:logger} = require "../logger"

seedDataset0 = require "./datasets/seedDataset0"
seedDataset1 = require "./datasets/seedDataset1"
seedDataset2 = require "./datasets/seedDataset2"
seedDataset3 = require "./datasets/seedDataset3"
seedDataset4 = require "./datasets/seedDataset4"
seedDataset5 = require "./datasets/seedDataset5"
seedDatasetOGD1 = require "./datasets/seedDatasetOGD1"
seedDatasetOGD2 = require "./datasets/seedDatasetOGD2"
seedDatasetSHP1 = require "./datasets/seedDatasetSHP1"

seedDatasets = [seedDataset0, seedDataset1, seedDataset2, seedDataset3, seedDataset4, seedDataset5, seedDatasetOGD1, seedDatasetOGD2, seedDatasetSHP1]

getRandomEntry = (val) ->
    return Math.floor(Math.random() * val.length) if Array.isArray val
    return Math.floor(Math.random() * val)

module.exports = (db, users, categories, tags) ->
    Dataset = db.model "Dataset"
    User = db.model "User"

    Dataset.find {}, (err, datasets) ->
        if datasets.length is 0
            console.log "No datasets available in datasets collection"

            Promise.all [users, categories, tags]
            .then (result) ->
                users = result[0]
                categories = result[1]
                tags = result[2]

                return if users.length is 0

                for seedDataset, i in seedDatasets
                    console.log "Inserting dataset #{i} (#{seedDataset.metaData.name}) for seed user #{i % users.length}"

                    seedDataset.metaData.categoryId = categories[getRandomEntry(categories)]._id
                    seedDataset.metaData.userId = users[i % users.length]._id

                    # create 0 to 3 tags for each dataset
                    seedDataset.metaData.tagIds = []
                    for [i..(getRandomEntry(4))]
                        tagId = tags[getRandomEntry(tags) % tags.length]._id
                        seedDataset.metaData.tagIds.push tagId

                    Dataset.create seedDataset
                    , (error, dataset) ->
                        console.log "Error inserting Dataset", error
                        return
        else
            console.log "No need to seed datasets"
