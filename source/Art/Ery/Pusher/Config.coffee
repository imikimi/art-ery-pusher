{defineModule, Configurable} = require 'art-foundation'

defineModule module, class ArtEryPusherConfig extends Configurable
  @defaults
    appId:  "..."
    key:    "..."
    secret: "..."

    # increase logging level with interesting stuff
    verbose: false

    pusherEventName: "changed"

    host: "https://api.pusherapp.com"

  getPusherChannel: (pipeline, key) ->
    [ArtEry.config.tableNamePrefix, pipeline, pipeline.toKeyString key].join '//'

  @configured: ->
    super
    @pusher = @config.newPusher?()
