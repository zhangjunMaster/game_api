crypto = require 'crypto'
express = require 'express'
router = express.Router()
zlib = require 'zlib'
_ = require 'underscore'

algorithm = "aes-128-cbc"
password = new Buffer('\xfa\x0d\x4c\x2b\x17\x3b\xb0\x8c\x05\x7f\x4e\xa9') #16位
iv = new Buffer('\x2f\x0b\0\x3b\0\x3a\x8e\xd6\0\x01\xc7\x3f\x2d')

module.exports = (req, res, next) ->
  return res.send {result: 0, err: '数据错误'} unless _.isEmpty req.body
  decipher = crypto.createDecipheriv algorithm, password, iv
  req.on 'data', (result) ->
    try
      decipher = crypto.createDecipheriv algorithm, password, iv
      decrypted = decipher.update result
      decrypted = Buffer.concat [decrypted, decipher.final()]
      zlib.unzip decrypted, (err, unzipbuf) ->
        bufStr = unzipbuf?.toString 'utf8'
        try
          obj = JSON.parse bufStr
          req.body = obj if typeof bufStr == 'string'
          next()
        catch err
          console.log err
    catch err
      res.send {result: 0} if err
