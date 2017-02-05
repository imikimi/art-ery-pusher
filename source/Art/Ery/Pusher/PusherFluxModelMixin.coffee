{
  defineModule, log, merge
} = require 'art-foundation'

{config} = Config = require './Config'
{session} = require 'art-ery'
defineModule module, -> (superClass) -> class PusherFluxModelMixin extends superClass
  constructor: ->
    super
    @_channels = {}
    @_listeners = {}

  ####################
  # FluxModel Overrides
  ####################
  fluxStoreEntryUpdated: ({key, subscribers}) ->
    @_subscribe key if subscribers.length > 0  # have local subscribers
    super

  fluxStoreEntryRemoved: ({key}) ->
    @_unsubscribe key
    super

  ####################
  # PRIVATE
  ####################
  _getPusherChannel: (key) ->
    Config.getPusherChannel @name, key

  # Pusher has the concept of subscribe & bind
  # This does both in one step.
  # If config.pusher isn't defined: noop
  _subscribe: (key) ->
    {pusherEventName} = config
    {pusherClient} = Config
    return unless pusherClient

    @_channels[key] ||= pusherClient.subscribe @_getPusherChannel key
    unless @_listeners[key]
      @_channels[key].bind pusherEventName, @_listeners[key] = (pusherData) => @_processPusherChangedEvent pusherData

  # If config.pusher isn't defined: noop
  _unsubscribe: (key) ->
    {pusherEventName} = config
    {pusherClient} = Config
    return unless pusherClient && @_channels[key]

    # unbind
    if @_listeners[key]
      @_channels[key]?.unbind pusherEventName, @_listeners[key]
      delete @_listeners[key]

    # unsubscribe
    pusherClient.unsubscribe @_getPusherChannel key
    delete @_channels[key]

  _processPusherChangedEvent: ({key, sender, updatedAt}) =>
    if sender == session.data.artEryPusherSession
      log "saved 1 reload due to sender check! (model: #{@name}, key: #{key})"
      return

    model = @recordsModel || @

    if (fluxRecord = model.fluxStoreGet key) && fluxRecord.updatedAt >= updatedAt
      log "saved 1 reload due to updatedAt check! (model: #{@name}, key: #{key})"
      return

    model.loadPromise key
