crypto = require 'crypto'
config = require '../config'

sha1 = (data) ->
  hash = crypto.createHash 'sha1'
  hash.update data, 'utf8'
  hash.digest 'hex'

md5 = (data) ->
  hash = crypto.createHash 'md5'
  hash.update data, 'utf8'
  hash.digest 'hex'

genPassword = (userId, password) ->
  md5 '' + password + userId

getDrawRefreshTime = ->
  date = new Date()
  new Date date.getFullYear(), date.getMonth(), date.getDate(), config.drawRefreshTime.hours, config.drawRefreshTime.minutes

getNextCanDrawCoupon = (newUser) ->
  if newUser.coupon < 120
    return true
  else if newUser.coupon < 2920
    if (30 / newUser.coupon) > Math.random()
      return true
  false

module.exports = {sha1, md5, genPassword, getDrawRefreshTime, getNextCanDrawCoupon, draw}
