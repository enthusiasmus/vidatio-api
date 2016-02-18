"use strict"

seedDatasets = [
    [ [200, 300, 400], ["Orange", "Banane", "Apfel"] ]
    [ ["Einnahmen", 100, 200, 300, 400], ["Ausgaben", 10, 20, 30, 40] ]
    [ [13.084850, 13.087736, 13.086685, 13.086181, 13.086172, 13.089662], [47.723955, 47.725081, 47.724881, 47.724186, 47.722308, 47.722749], ["Bank", "Post", "FH", "Spar", "Vidatio", "Wohnung"] ]
    [ [200, 300, 400], [500, 600, 700] ]
    [ ["01.01.2014", "01.01.2015", "01.01.2016"], ["Idee Vidatio", "Umsetzung Vidatio", "Gewinn Vidatio"] ]
]

module.exports =  (db, users) ->
    Dataset = db.model "Dataset"
    User = db.model "User"

    Dataset.find {}, (err, datasets) ->
        if datasets.length == 0
            console.log "No datasets available in datasets collection"

            users.then (result) ->
                User.find {}, (err, users) ->
                    if users.length isnt 0
                        for user, i in users
                            console.log "Inserting dataset #{i % seedDatasets.length} for seed user #{i}"
                            Dataset.create
                                name: "Dataset from #{user.name}"
                                userId: user._id
                                data: seedDatasets[i % seedDatasets.length]
        else
            console.log "No need to seed datasets"
