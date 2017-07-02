{log, ConfigRegistry, merge} = require 'art-foundation'

require 'art-ery-pusher/Server'
Server  = require 'art-ery/Server'
require "./test/tests/Art.EryExtensions.Pusher/Pipelines"

require "./test/TestConfig"

ConfigRegistry.configure
  artConfigName: "Test"
  # artConfig:
  #   verbose: true
  #   Art:
  #     Ery:
  #       verbose: true
  #       Pusher: merge
  #         verifyConnection: true
  #         verbose: true
  #         require "./.TestPusherAppCredentials"

###
NOTE: .TestPusherAppCredentials.coffee should look like this:
module.exports =
  appId:  '...'
  key:    '...'
  secret: '...'
###

Server.start
  static: root: "./test/public/"
