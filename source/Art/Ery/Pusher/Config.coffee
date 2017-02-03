{defineModule, Configurable, log, isString} = require 'art-foundation'
ArtEry = require 'art-ery'

defineModule module, class ArtEryPusherConfig extends Configurable
  ###
  /Client.coffee and /Server.coffee set this appropriatly:
  Should be a function: () -> pusher instance
    IN: nothing
    OUT: pusher instance

  NOTE: Pusher has a different library for server-side and client-side.
    They are rather inconsistent. Their constructors take different argument structures.
    Their API's aren't even very similar.
  ###
  @newPusher: null

  @defaults
    appId:  "..."
    key:    "..."
    secret: "..."

    encrypted: true

    # increase logging level with interesting stuff
    verbose: false

    # if true, will do a test call to pusher after configured. Logs results.
    verifyConnection: false

    pusherEventName: "changed"

    host: "api.pusherapp.com"

  # legal channel names: https://pusher.com/docs/client_api_guide/client_channels
  # I think this matches legal channel names: /^[-a-zA-Z0-9_=@,.;]+$/
  encodeKeyString = (key) ->
    # any character that is illegal OR "." is replaced with ";"
    key.replace /[^-a-zA-Z0-9_=@,;]/g, ";"

  ###
  IN:
    pipeline: string or pipeline
    key: string or plain object
      if plain object, must provide a pipeline that implements toKeyString
  ###
  @getPusherChannel: (pipeline, key) ->
    unless isString key
      key = pipeline.toKeyString key
    unless isString pipeline
      pipeline = pipeline.getName()

    [ArtEry.config.tableNamePrefix, pipeline, encodeKeyString key].join '.'

  @configured: ->
    super
    {verbose, verifyConnection, key} = @config
    if @PusherClient
      pusher = @pusherClient = new @PusherClient key

      verbose && log "ArtEryPusher: PusherClient initialized"

      verifyConnection && @pusherClient.connection.bind 'state_change', (data) ->
        log "ArtEryPusher: pusher state change": data

    else if @PusherServer
      @pusherServer = new @PusherServer log "pusher config", @config

      verbose && log "ArtEryPusher: PusherServer initialized"
      verifyConnection && @pusherServer.trigger 'ArtEryPusherConfig', "server", message: "ArtEryPusher: verifyConnection: pusher was initialized correctly", (error, request, response) ->
        if error
          log.error "ArtEryPusher: PusherServer not initialized correctly! trigger-attempt error: #{error}"
          console.log error
        else
          log "ArtEryPusher: PusherServer initialized correctly."

    else
      if verbose
        log "ArtEryPusher disabled. Require: art-ery-pusher/Client or art-ery-pusher/Server"
