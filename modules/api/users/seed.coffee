"use strict"

seedUsers = 10
count = 0

createUser = (User, i) ->
    return new Promise (resolve, reject) ->
        User.create
            email:  "user#{i}@vidatio.com"
            name: "user#{i}"
            password: "user#{i}"
        , (error, user) ->
            reject error if error
            resolve user

module.exports =  (db) ->
    promiseArray = []
    User = db.model "User"

    return new Promise (resolve, reject) ->
        User.find {}, (error, users) ->
            reject error if error
            if users.length is 0
                console.log "No users available in users collection"

                for i in [1..seedUsers]
                    console.log "Inserting user #{i}"
                    promiseArray.push(createUser(User, i))

                Promise.all(promiseArray)
                .then (result) ->
                    resolve result
                , (error) ->
                    reject error
            else
                console.log "No need to seed users"
                resolve true
