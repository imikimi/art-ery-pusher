{defineModule, array, randomString, merge} = require 'art-foundation'
{PusherPipelineMixin} = require 'art-ery-pusher'
{Pipeline, KeyFieldsMixin} = require 'art-ery'

defineModule module, class SimpleStore extends PusherPipelineMixin KeyFieldsMixin Pipeline

  @remoteServer "http://localhost:8085"

  constructor: ->
    super
    @db = {}

  @query
    pusherTestsByNoodleId:
      query: ({key}) -> array @db, when: (v, k) -> v.noodleId == key
      toKeyString: ({noodleId}) -> noodleId

  @handlers
    get: ({key}) ->
      @db[key]

    create: (request) ->
      key = randomString().slice 0, 8
      @db[key] = merge request.data, id: key

    update: (request) ->
      {data, key} = request
      key ||= request.pipeline.toKeyString data
      return null unless @db[key]
      @db[key] = merge @db[key], data

    delete: (request) ->
      {key} = request
      key ||= request.pipeline.toKeyString data
      return null unless @db[key]
      out = @db[key]
      delete @db[key]
      out
