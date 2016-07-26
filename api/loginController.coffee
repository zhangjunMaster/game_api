User = require '../models/user'
utils = require '../utils'
_ = require 'underscore'
resultUtils = require '../utils/resultUtils'
config = require '../config'
redisClient = require '../utils/redisClient'
log = require '../winston/log'

module.exports = (req, res, next) ->
  return next() unless req.protoVerMain == 2
  comHeader = req.body?.comHeader
  userId = req.body?.userId
  password = req.body?.password
  tele = req.body?.tele
  token = utils.md5 password + comHeader?.localTimestamp
  hasParamas = true if password and (tele or userId )
  log 'login', 'request', req.body
  return res.send resultUtils.getResultMsg 101 if !hasParamas or _.isEmpty comHeader
  condition = {}
  condition.userId = userId if userId
  condition.tele = tele if tele
  condition.password = password
  key = "tyddz:token:#{userId}"
  redisClient.multi().hmset(key, {
    "userId": userId
    "token": token
  }).expire(key, config.tokenValid).exec (err, result) ->
    if err
      log 'login', '1,redis,hmset,err', {err, userId, password}
      return res.send resultUtils.getResultMsg 1000
    User.findOne condition, (err, user) ->
      if err or not user
        log 'login', '2,user,find,err', {err, condition, token} if err
        return res.send resultUtils.getResultMsg 1001
      {tele,name, sex, jCoin,userId, rechargeCard, gold,lastDrawTimeV2} = user
      newDate = new Date()
      lastDate = new Date(lastDrawTimeV2) if lastDrawTimeV2?
      isFirstDraw = lastDate?.getDate() < newDate.getDate()
      if !lastDrawTimeV2 or isFirstDraw
        user.nextCanFreeDraw = true
        newUser = utils.draw(user)
        {nextDrawType,nextDrawNum} = newUser unless _.isEmpty newUser
        user.nextDrawType = nextDrawType
        user.nextDrawNum = nextDrawNum
      legalUrl = config.legalUrl
      content = {config: config.migu, token, name, sex, jCoin, rechargeCard, gold, tele, legalUrl}
      _.extend content, {nextCanFreeDraw: user.nextCanFreeDraw}
      user.save (err) ->
        if err
          log 'login', 'user,save,err', {err, userId, password}
          return res.send resultUtils.getResultMsg 1081, err
        content.people = []
        res.send _.extend resultUtils.getResultMsg(1), content
        log 'login', 'result', {content}

