"use strict"

{api:logger} = require "../logger"

seedDataset0 = require "./datasets/seedDataset0"
seedDataset1 = require "./datasets/seedDataset1"
seedDataset2 = require "./datasets/seedDataset2"
seedDataset3 = require "./datasets/seedDataset3"
seedDataset4 = require "./datasets/seedDataset4"
seedDataset5 = require "./datasets/seedDataset5"

seedDatasets = [seedDataset0, seedDataset1, seedDataset2, seedDataset3, seedDataset4, seedDataset5]

getRandomEntry = (val) ->
    return Math.floor(Math.random() * val.length) if Array.isArray val
    return Math.floor(Math.random() * val)

module.exports = (db, users, categories, tags) ->
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

                return if users.length is 0

                for seedDataset, i in seedDatasets
                    console.log "Inserting dataset #{i} for seed user #{i % users.length}"

                    seedDataset.metaData.categoryId = categories[getRandomEntry(categories)].upserted[0]._id
                    seedDataset.metaData.userId = users[i % users.length]._id

                    # create 0 to 3 tags for each dataset
                    for [i..(getRandomEntry(4))]
                        tagId = tags[getRandomEntry(tags) % tags.length].upserted[0]._id
                        seedDataset.metaData.tags tagId

                    Dataset.create seedDataset
                    , (error, dataset) ->
                        return
        else
            console.log "No need to seed datasets"
