"use strict"

seedTags = [
    "Vidatio"
    "Visualization"
    "FH Salzburg"
    "Luftgüte"
    "OGD"
    "Impfung"
    "2015"
    "Schule"
    "Salzburg"
    "Kartenvisualisierung"
    "Arbeitslosigkeit"
    "Ausland"
    "Asyl"
    "Arzt"
    "Ausbildung"
    "Barrierefreiheit"
    "Datenvisualisierung"
    "Datenanalyse"
]

module.exports =  (db) ->
    promiseArray = []
    Tag = db.model "Tag"

    return new Promise (resolve, reject) ->
        Tag.find {}, (err, tags) ->
            if tags.length < seedTags.length
                console.log "No or not enough tags available in tags collection"

                for tag, i in seedTags
                    console.log "Inserting tag #{seedTags[i]}"

                    promise = new Promise (resolve, reject) ->
                        Tag.update
                            name: seedTags[i]
                        ,
                            $setOnInsert:
                                name: seedTags[i]
                        ,
                            upsert: true
                        , (error, doc) ->
                            reject error if error
                            resolve doc.upserted[0]

                    promiseArray.push promise

                Promise.all(promiseArray)
                .then (result) ->
                    resolve result
                , (error) ->
                    reject error

            else
                console.log "No need to seed tags"
                resolve tags
