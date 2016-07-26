DbActivity = require '../models/dbActivity'
config = require '../config'
redis = require 'redis'
redisClient = require '../utils/redisClient'
_ = require 'underscore'

#use publish/subscribe of redis to synchronous data
ACTIVITIES_CACHE_UPDATE_CHANNEL = "cache:activities:update:channel"
ACTIVITIES_CACHE_DELETE_CHANNEL = "cache:activities:delete:channel"

activitiesMap = {}

startSub = ->
  sub = redis.createClient config.redis.port, config.redis.host
  sub.subscribe ACTIVITIES_CACHE_UPDATE_CHANNEL
  sub.subscribe ACTIVITIES_CACHE_DELETE_CHANNEL
  sub.on 'message', (channel, data) ->
    switch channel
      when ACTIVITIES_CACHE_UPDATE_CHANNEL
        console.log "#{ACTIVITIES_CACHE_UPDATE_CHANNEL} #{data}"
        try
          activity = JSON.parse data
          if activity?.activityId
            if activitiesMap[activity.activityId]
              _.extend activitiesMap[activity.activityId], activity
            else
              activitiesMap[activity.activityId] = activity
      when ACTIVITIES_CACHE_DELETE_CHANNEL
        try
          activity = JSON.parse data
          delete activitiesMap[activity.activityId] if activity?.activityId

now = Math.ceil Date.now() / 1000
DbActivity.find {activityStart: {$gt: now - (90 * 24 * 60 * 60)}}, (err, activities) ->
  _.each activities, (activity) ->
    activitiesMap[activity.activityId] = activity if activity?.activityId

update = (activity...) ->
  activity = _.extend {}, activity...
  redisClient.publish ACTIVITIES_CACHE_UPDATE_CHANNEL, JSON.stringify activity if activity?.activityId

module.exports = {activitiesMap, startSub, update}
