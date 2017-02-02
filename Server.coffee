Pusher = require 'pusher'

ArtEryPusher = require './index'
.config.newPusher = -> new Pusher @

module.exports = ArtEryPusher
