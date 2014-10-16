#!/usr/bin/env node
debug = require('debug')('hello')
app = require('../app')

app.set('port', process.env.PORT || 3000)

server = app.listen app.get('port'), () ->
  debug('Express server listening on port ' + server.address().port)
