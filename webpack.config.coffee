module.exports = (require "art-foundation/configure_webpack")
  entries: "index test"
  dirname: __dirname
  package:
    scripts:
      testServer: "coffee ./TestServer.coffee"

    description: "Art App/Lib Boilerplate"
    dependencies:
      "art-foundation": "git://github.com/imikimi/art-foundation.git"
      "pusher-js":  "^4.0.0"  # client
      "pusher":     "^1.5.1"  # server
