{defineModule, log, Config, merge} = require 'art-foundation'

defineModule module, class Test extends Config
  verbose: true
  Art:
    Ery:
      verbose: true
      Pusher: merge
        verifyConnection: true
        verbose: true
        require "../.TestPusherAppCredentials"

