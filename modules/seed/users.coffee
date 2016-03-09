"use strict"

createUser = (User, i) ->
    return new Promise (resolve, reject) ->
        User.create
            email:  "user#{i}@vidatio.com"
            name: "user#{i}"
            password: "password#{i}"
        , (error, user) ->
            reject error if error
            resolve user

module.exports =  (db, seedNumberUsers) ->
    promiseArray = []
    User = db.model "User"

    return new Promise (resolve, reject) ->
        User.find {}, (error, users) ->
            reject error if error
            if users.length is 0
                console.log "No users available in users collection"

                for i in [1..seedNumberUsers]
                    console.log "Inserting user #{i}"
                    promiseArray.push(createUser(User, i))

                Promise.all(promiseArray)
                .then (result) ->
                    resolve result
                , (error) ->
                    reject error
            else
                console.log "No need to seed users"
                resolve users
