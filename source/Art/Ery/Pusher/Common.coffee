{defineModule} = require 'art-foundation'
ArtEry = require 'art-ery'

defineModule module,
  getPusherChannel: (pipeline, key) ->
    [ArtEry.config.tableNamePrefix, pipeline, pipeline.toKeyString key].join '//'

  pusherEventName: "changed"