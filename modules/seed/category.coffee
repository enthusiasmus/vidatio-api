"use strict"

seedCategories = [
    "Politik"
    "Sport"
    "Finanzen"
    "Umwelt"
    "Bildung"
]

module.exports =  (db) ->
    Category = db.model "Category"

    Category.find {}, (err, categories) ->
        if categories.length < seedCategories.length
            console.log "No or not enough categories available in categories collection"

            for category, i in seedCategories
                console.log "Upserting category #{seedCategories[i]}"
                Category.update
                    name: seedCategories[i]
                ,
                    $set:
                        name: seedCategories[i]
                ,
                    upsert: true
                , (err, doc) ->
                    if err then console.error err

        else
            console.log "No need to seed categories"
