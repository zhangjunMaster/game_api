later = require 'later'
redisClient = require '../utils/redisClient'

later.date.localTime()
#here is the game announcement
notices = []
updateNoticeTask = ->
  notices.splice 0, notices.length
  redisClient.llen 'tyddz:notices', (err, len) ->
    console.log 'llen tyddz:notices -> ' + len
    start = Math.floor Math.random() * len
    redisClient.lrange 'tyddz:notices', start, start + 9, (err, replies) ->
      console.log 'lrange tyddz:notices -> ' + replies?.length
      if replies
        for reply in replies
          notices.push reply
      console.log 'notices = ' + JSON.stringify notices

updateNoticeTask()
later.setInterval updateNoticeTask, later.parse.cron "0/5 * * * *"

module.exports = {notices}
