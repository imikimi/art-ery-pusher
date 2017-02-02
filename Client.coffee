Pusher = require 'pusher-js'

ArtEryPusher = require './index'
.config.newPusher = -> new Pusher @key

module.exports = ArtEryPusher
