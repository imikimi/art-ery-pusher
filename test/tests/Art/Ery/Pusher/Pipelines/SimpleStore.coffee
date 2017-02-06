{object, defineModule, log, array, randomString, merge} = require 'art-foundation'
{PusherPipelineMixin} = require 'art-ery-pusher'
{Pipeline, KeyFieldsMixin} = require 'art-ery'

defineModule module, class SimpleStore extends PusherPipelineMixin KeyFieldsMixin Pipeline

  @remoteServer "http://localhost:8085"

  @filter
    location: "client"
    name: "fakeDataUpdatesFilter"
    after: get: (response) ->
      {key, responseData, pipeline, pipelineName} = response
      key ||= pipeline.toKeyString responseData
      Neptune.Art.Flux.models[pipelineName].dataUpdated key, responseData
      response

  constructor: ->
    super
    @db = {}

  @query
    pusherTestsByNoodleId:
      query: ({key}) -> array @db, when: (v, k) -> v.noodleId == key
      dataToKeyString: ({noodleId}) -> noodleId

  @handlers
    reset: ({data}) -> @db = object data, (v, k) -> merge v, id: k

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
