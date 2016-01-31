User = require("mongoose").model("User")

module.exports = (cb) ->
    console.log "users/seed.coffee"
    User.find({}).exec (err, users) ->
        console.log "user.find something?!"
        if users.length == 0
            console.log "No users present in users collection"
            for i in [1..10]
                console.log "Inserting user #{i}"
                User.create
                    email:  "user#{i}@vidatio.com"
                    name: "user#{i}"
                    password: "user#{i}"

            return cb true
        else
            console.log "No need to seed"
            return cb false
