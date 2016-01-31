module.exports =  (db) ->
    User = db.model "User"
    User.find {}, (err, users) ->
        if users.length == 0
            console.log "No users available in users collection"
            for i in [1..10]
                console.log "Inserting user #{i}"
                User.create
                    email:  "user#{i}@vidatio.com"
                    name: "user#{i}"
                    password: "user#{i}"
        else
            console.log "No need to seed users"
