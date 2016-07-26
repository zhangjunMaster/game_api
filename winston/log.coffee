winston = require 'winston'
path = require 'path'
winstonRotate = require 'winston-daily-rotate-file'
fs = require 'fs'

logPath = path.join __dirname, '..', 'log'
fs.readdir path.join(__dirname, '..', 'apiv2'), (err, files) ->
  for file in files
    do (file) ->
      if m = file.match /^(\w+)Controller\.js$/
        dirName = m[1]
        dirPath = path.join(__dirname, '..', 'log', dirName)
        fs.exists dirPath, (exists) ->
          fs.mkdir dirPath unless exists

fs.exists path.join(__dirname, '..', 'log', 'api'), (exists) ->
  fs.mkdir path.join(__dirname, '..', 'log', 'api') unless exists

log = (logName, logType, logInfo) ->
  logger = new (winston.Logger)({
    transports: [
      new (winstonRotate)({
        name: "#{logName}-info-file",
        filename: path.join(logPath, "#{logName}", "#{logName}.info.log"),
        level: 'info',
        datePattern: 'yyyy-M-d'
      }),
      new (winstonRotate)({
        name: "#{logName}-error-file",
        filename: path.join(logPath, "#{logName}", "#{logName}.error.log"),
        level: 'error',
        datePattern: 'yyyy-M-d'
      })
    ]
  })
  logger.log('info', "#{logType}", logInfo)
  logger.log('error', "#{logType}", logInfo) if /err/.test logType

module.exports = log
