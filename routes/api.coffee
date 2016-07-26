express = require 'express'
router = express.Router()
fs = require 'fs'
config = require '../config.json'
utils = require '../utils'
resultUtils = require '../utils/resultUtils'
path = require 'path'
_ = require 'underscore'
redisClient = require '../utils/redisClient'
log = require '../winston/log'
decipher = require '../utils/decipher'
cipher = require '../utils/cipher'

signCheck = (req, res, next) ->

  next()

tokenCheck = (req, res, next) ->
  next()

pricyCheck = (req, res, next) ->
  userId = req.body?.userId
  token = req.body?.token
  return res.send resultUtils.getResultMsg 101 unless userId and token

apiRouters = {}

for apiSrc in ['../api', '../apiOtherVersion']
  files = fs.readdirSync path.join __dirname, apiSrc
  for file in files
    if m = file.match /^(\w+)Controller\.js$/
      name = '/' + m[1]
      api = require apiSrc + '/' + file
      if apiRouters[name]
        apiRouters[name].push api
      else
        apiRouters[name] = [api]
reg = /^\/(spDbOrderUpdate|thirdDbOrderUpdate)/
_.each apiRouters, (apis, name) ->
  params = [name]
  params.push signCheck
  params.push apis
  router.all.apply router, params

mrPath = path.join(__dirname, '..', 'mr')
fs.readdir mrPath, (err, files) ->
  if !_.isEmpty files
    for file in files
      do (file) ->
        if m = file.match /^(\w+)\.js$/
          name = m[1]
          router.use "/#{name}", require path.join mrPath, name

module.exports = router
