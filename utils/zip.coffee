zlib = require 'zlib'
_ = require 'underscore'


zip = (data, cb) ->
  data = JSON.stringify data if typeof data == 'object'
  zlib.gzip data, (err, buf) ->
    return if err or not buf
    bufInstr = ''
    for i in [0...buf.length]
      bufInstr += buf[i].toString(16)
    cb err, bufInstr

unzip = (data, cb) ->
  return console.log 'no string' unless _.isString data
  zipbuf = new Buffer data, 'hex'
  zlib.unzip zipbuf, (err, unzipbuf) ->
    return console.log {err, unzipbuf} if err or not unzipbuf
    bufStr = unzipbuf.toString 'utf8'
    cb err, bufStr

module.exports = unzip
