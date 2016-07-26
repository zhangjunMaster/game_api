mongoose = require 'mongoose'

schema = new mongoose.Schema
  userId: {type: Number, unique: true} # 用户ID
  protoVer: String # 协议版本
  projectId: String # 项目号

schema.index {userId: -1}

module.exports = mongoose.model 'User', schema
