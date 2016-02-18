class Config
    constructor: ->
        @apiVersion = "v0"
        @port = 3000
        @host = "localhost"
        @url = "http://#{@host}:#{@port}"
        @db =
            host: "localhost"
            name: "vidatio"
        @dirs =
            log: "./logs"

        @mongo  = do =>
            if @isDevEnvironment()
                return "#{ @db.host }/#{ @db.name }_test"
            return "#{ @db.host }/#{ @db.name }"

    isDevEnvironment: ->
        process.env.NODE_ENV is "development" or process.env.NODE_ENV is "test"

module.exports = new Config
