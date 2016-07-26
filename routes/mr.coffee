express = require 'express'
router = express.Router()
fs = require 'fs'
config = require '../config'
utils = require '../utils'
resultUtils = require '../utils/resultUtils'
path = require 'path'
_ = require 'underscore'
redisClient = require '../utils/redisClient'

mrPath = path.join(__dirname, '..', 'mr')
fs.readdir mrPath, (err, files) ->
  if !_.isEmpty files
    for file in files
      do (file) ->
        if m = file.match /^(\w+)\.js$/
          name = m[1]
          console.log "/#{name}"
          router.use "/#{name}", require path.join mrPath, name

module.exports = router
