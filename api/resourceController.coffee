User = require '../models/user'
Acount = require '../models/acount'
utils = require '../utils'
config = require '../config'
_ = require 'underscore'
resultUtils = require '../utils/resultUtils'
config = require '../config'
redisClient = require '../utils/redisClient'
path = require 'path'
fs = require 'fs'
Resource = require '../models/resource'
log = require '../winston/log'

module.exports = (req, res, next) ->
  return next() unless req.protoVerMain == 2
  comHeader = req.body?.comHeader
  localVersion = req.body?.localVersion
  log 'resource', 'request', req.body
  return res.send resultUtils.getResultMsg 101 if  _.isEmpty(comHeader) and !localVersion
  Resource.findOne {}, (err, resource) ->
    if err or not resource
      log 'resource', 'resouse,findOne,err', {err} if err
      return res.send resultUtils.getResultMsg 1201
    #    return res.send resultUtils.getResultMsg 1201
    {updateUrl, fileSize, serverVersion} = resource
    fileSize = resource.fileSize
    serverVersion = resource.serverVersion
    if localVersion >= serverVersion
      log 'resource', 'localVersion >= serverVersion', {localVersion, serverVersion}
      return res.send resultUtils.getResultMsg 1201
    res.send _.extend resultUtils.getResultMsg(1), {updateUrl, fileSize, serverVersion}
    log 'resource', 'result', {updateUrl, fileSize, serverVersion}
