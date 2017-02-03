{
  defineModule, log, merge
} = require 'art-foundation'

{config} = Config = require './Config'
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
    Config.getPusherChannel @pipeline.name, key

  # Pusher has the concept of subscribe & bind
  # This does both in one step
  # If config.pusher isn't defined: noop
  _subscribe: (key) ->
    {pusherEventName} = config
    {pusherClient} = Config
    return unless pusherClient

    @_channels[key] ||= pusherClient.subscribe @_getPusherChannel key
    unless @_listeners[key]
      @_channels[key].bind pusherEventName, @_listeners[key] = (pusherEventData) =>
        # TODO
        # If this isn't a query model && pusherEventData.type == "delete"
        #   then we can just set status: missing without triggering a reload
        # If this is a query model, we can remove the deleted record
        #   but we need the record's id to be in the pusherEventData...
        @load key

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
