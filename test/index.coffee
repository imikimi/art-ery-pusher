require '../Client'
require './TestConfig'
require "art-foundation/testing"
.init
  artConfigName: "Test"
  defineTests: -> require './tests'
