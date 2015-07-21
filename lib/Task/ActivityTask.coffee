_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Task = require "../Task"

class ActivityTask extends Task
  constructor: (options, dependencies) ->
    Match.check dependencies, Match.ObjectIncluding
      in: Match.Where (stream) -> Match.test(stream.read, Function) # stream.Readable or stream.Duplex
      out: Match.Where (stream) -> Match.test(stream.write, Function) # stream.Writable or stream.Duplex
    super
  execute: -> throw new Error("Implement me!")
  # temp progress stubs
  progressInit: (total) -> Promise.resolve().thenReturn(total)
  progressInc: (inc) -> Promise.resolve().thenReturn(inc)
  progressFinish: -> Promise.resolve()

module.exports = ActivityTask