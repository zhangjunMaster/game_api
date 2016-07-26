winston = require 'winston'

options = {
  from: new Date() - 24 * 60 * 60 * 1000,
  until: new Date(),
  limit: 10,
  start: 0,
  order: 'desc',
  fields: ['message']
}

console.log new Date()
query = () ->
  options = {
    from: new Date() - 24 * 60 * 60 * 1000,
    until: new Date(),
    limit: 10,
    start: 0,
    order: 'desc',
    fields: ['message']
  }
  winston.query options, (err, result) ->
    console.log "result", result

module.exports = query