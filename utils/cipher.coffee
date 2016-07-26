crypto = require 'crypto'
express = require 'express'
zlib = require 'zlib'
router = express.Router()
_ = require 'underscore'

algorithm = "aes-128-cbc"
password = new Buffer('\xfa\x0d\x4c\x2b\x17\x3b\xb0\x8c\x05\x7f\x4e\xa9') #16位
iv = new Buffer('\x2f\x0b\0\x3b\0\x3a\x8e\xd6\0\x01\xc7\x3f\x2d')

module.exports = (req, res, next) ->
  send = res.send
  res.send = (data) ->
    try
      data = JSON.stringify data if typeof data == 'object'
      zlib.gzip data, (err, buf) ->
        try
          cipher = crypto.createCipheriv algorithm, password, iv
          encrypted = cipher.update buf
          bufferCrypted = Buffer.concat [encrypted, cipher.final()]
          res.set({'Content-Type': 'application/octet-stream'}).end bufferCrypted
    catch err
      res.end err
    res.send = send
  next()
