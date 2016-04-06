"use strict"

seedDataset0 = require "./datasets/seedDataset0"
seedDataset1 = require "./datasets/seedDataset1"
seedDataset2 = require "./datasets/seedDataset2"
seedDataset3 = require "./datasets/seedDataset3"
seedDataset4 = require "./datasets/seedDataset4"
seedDataset5 = require "./datasets/seedDataset5"
seedDatasetOGD1 = require "./datasets/seedDatasetOGD1"
seedDatasetOGD2 = require "./datasets/seedDatasetOGD2"
seedDatasetSHP1 = require "./datasets/seedDatasetSHP1"

seedDatasets = [
    {data: seedDataset0}
    {data: seedDataset1}
    {data: seedDataset2}
    {data: seedDataset3}
    {data: seedDataset4}
    {data: seedDataset5}
    {data: seedDatasetOGD1}
    {data: seedDatasetOGD2}
    {data: seedDatasetSHP1}
]

seedDatasetsOGD = [
    {
        data: seedDatasetOGD1
        category: "Bildung"
        tags: ["Schule", "Salzburg", "OGD"]
    }
    {
        data: seedDatasetOGD2
        category: "Umwelt"
        tags: ["OGD", "Luftgüte", "Kartenvisualisierung"]
    }
    {
        data: seedDatasetSHP1
        category: "Gesundheit"
        tags: ["Impfung", "OGD", "Salzburg", "2015"]
    }
]

getRandomEntry = (val) ->
    return Math.floor(Math.random() * val.length) if Array.isArray val
    return Math.floor(Math.random() * val)

getUniqueTagId = (seedDataset, tags) ->
    tagId = tags[getRandomEntry(tags) % tags.length]._id
    if tagId in seedDataset.data.metaData.tagIds
        return getUniqueTagId seedDataset, tags
    return tagId

getCategoryByName = (name, categories) ->
    for category in categories
        return category if category.name is name

populateDevData = (seedDataset, categories, tags) ->
    console.log "populateDevData"
    seedDataset.data.metaData.categoryId = categories[getRandomEntry(categories)]._id
    seedDataset.data.metaData.tagIds = []
    numberOfTags = getRandomEntry (tags.length / 2)
    for i in [0..numberOfTags]
        tagId = getUniqueTagId seedDataset, tags
        seedDataset.data.metaData.tagIds.push tagId
    return seedDataset

populateProdData = (seedDataset, categories, tags) ->
    category = getCategoryByName seedDataset.category, categories
    seedDataset.data.metaData.categoryId = category._id
    for seedTag in seedDataset.tags
        for tag in tags
            if tag.name is seedTag
                tagId = tag._id
        seedDataset.data.metaData.tagIds.push tagId
    return seedDataset

module.exports = (db, users, categories, tags, useAllDatasets) ->
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

                if useAllDatasets
                    arrayToProcess = seedDatasets
                    seedFunction = populateDevData
                else
                    arrayToProcess = seedDatasetsOGD
                    seedFunction = populateProdData

                for data, i in arrayToProcess
                    console.log "Inserting dataset #{i} (#{data.data.metaData.name}) for seed user #{i % users.length}"
                    console.log "#{arrayToProcess.length}"
                    seedDataset = seedFunction data, categories, tags
                    seedDataset.data.metaData.userId = users[i % users.length]._id

                    console.log seedDataset.data.metaData
                    console.log "\n"

                    Dataset.create seedDataset.data
                    , (error, dataset) ->
                        console.log "Error inserting Dataset", error

        else
            console.log "No need to seed datasets"
