{defineModule, Configurable} = require 'art-foundation'

defineModule module, class ArtEryPusherConfig extends Configurable
  @defaults
    appId:  "..."
    key:    "..."
    secret: "..."

    # increase logging level with interesting stuff
    verbose: false
