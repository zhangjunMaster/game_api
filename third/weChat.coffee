request = require 'request'
config = require '../config'
_ = require 'underscore'

thirdLogin = (code, cb) ->
  return cb null, {} unless code
  appid = config.weChat.AppID
  secret = config.weChat.AppSecret
  data = {appid, secret, code, grant_type: 'authorization_code'}
  tokenUrl = 'https://api.weixin.qq.com/sns/oauth2/access_token'
  refreshTokenUrl = 'https://api.weixin.qq.com/sns/oauth2/refresh_token'
  userInfoUrl = 'https://api.weixin.qq.com/sns/userinfo'

  request {url: tokenUrl, method: 'get', qs: data, json: true}, (err, req, body) ->
    return cb err, null if err
    return cb null, {} if body.errcode
    {access_token,expires_in,refresh_token,openid,scope,unionid} = body
    return cb null, {} unless unionid
    _.extend data, {refresh_token}
    request {
      url: refreshTokenUrl, method: 'get', qs: {appid, grant_type: 'refresh_token', refresh_token}, json: true
    }, (err, req, body) ->
      return cb err, null if err
      return cb err, {} if body.errcode
      {access_token,expires_in,refresh_token,openid,scope} = body
      request {url: userInfoUrl, method: 'get', qs: {access_token, openid}, json: true}, (err, req, body) ->
        return cb err, null if err
        return cb null, {} if body.errcode
        {openid,nickname,sex,province,city,country,headimgurl,unionid} = body
        cb null, {nickname, sex, province, city, country, headimgurl, unionid}

module.exports = thirdLogin
