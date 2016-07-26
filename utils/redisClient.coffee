redis = require 'redis'
config = require '../config'

client = redis.createClient config.redis.port, config.redis.host
client.on "error", (err) ->
  console.log 'redisConnect', "Error " + err

module.exports = client
