User = require '../models/user'
Sequence = require '../models/sequence'
_ = require 'underscore'
utils = require '../utils'
resultUtils = require '../utils/resultUtils'
config = require '../config'
client = require '../utils/redisClient'
log = require '../winston/log'

module.exports = (req, res, next) ->
  return next() unless req.protoVerMain == 2
  comHeader = req.body?.comHeader
  log 'register', 'request', req.body
  return res.send resultUtils.getResultMsg 101 if _.isEmpty comHeader
  Sequence.findOneAndUpdate {name: 'user'}, {$inc: {nextId: 1}}, {new: true, upsert: true}, (err, sequence) ->
    if err or not sequence
      log 'register', 'Sequence.findOneAndUpdate,err', {err, name: 'user'} if err
      return res.send resultUtils.getResultMsg 1004, err
    userId = sequence.nextId
    password = utils.genPassword comHeader?.userId, '888888'
    token = utils.md5 password + comHeader?.localTimestamp
    {coupon, jCoin, rechargeCard, gold,nextCanFreeDraw,nextDrawType,nextDrawNum} = config.defaultValues
    key = "tyddz:token:#{userId}"
    client.multi().hmset(key, {
      "userId": userId
      "token": token
    }).expire(key, config.tokenValid).exec (err, result) ->
      if err
        log 'register', 'redis,hmset,err', {err, userId, token}
        return res.send resultUtils.getResultMsg 1000
      createContent = _.extend(comHeader,
        {userId, password, token, coupon, jCoin, rechargeCard, gold, nextCanFreeDraw, nextDrawType, nextDrawNum})
      User.create createContent, (err, user) ->
        if err or not user
          log 'register', 'User.create,err', {err, userId} if err
          return res.send resultUtils.getResultMsg 1004, err
        {userId, password, token, jCoin, rechargeCard, gold,nextCanFreeDraw} = user
        legalUrl = config.legalUrl
        sendCtent = {userId, password, token, jCoin, rechargeCard, gold, nextCanFreeDraw, config: config.migu, legalUrl}
        sendCtent.people = []
        res.send _.extend resultUtils.getResultMsg(1), sendCtent
        log 'register', 'result', {sendCtent}
