_ = require "underscore"
Promise = require "bluebird"
Read = require "../Read"

# It seems like this algorithm hangs for a while, then dump all downloaded info, but under heavy load, it dumps steadily, so most probably it's just some issue with stdout flush delay (caching or something)
class LimitOffset extends Read
  constructor: (input, options, dependencies) ->
    _.defaults input,
      limit: 100
      offset: 0
    super

  getTotalParams: -> throw new Error("Implement me!")
  getTotalRequest: (params) -> throw new Error("Implement me!")
  extractTotalFromResponse: (response, body) -> throw new Error("Implement me!")
  getPageParams: (limit, offset) -> throw new Error("Implement me!")
  getPageRequest: (params) -> throw new Error("Implement me!")

  execute: ->
    @count = 0
    Promise.bind(@)
    .then @acquireCredential
    .then -> @progressBarIncCurrent(0)
    .then @getTotal
    .then @progressBarSetTotal
    .then @readChapter
    .then -> @out.end()
    .then -> {count: @count}

  readChapter: (total) ->
    offset = @offset
    pages = []
    while offset <= total
      pages.push [@limit, offset]
      offset += @limit
    Promise.resolve(pages).bind(@)
    .map (args) ->
      @readPage(args...)
    , {concurrency: 10}

  getTotal: ->
    params = @getTotalParams()
    @info "LimitOffset:getTotalRequest", @details({params: params})
    @getTotalRequest(params).bind(@)
    .spread (response, body) ->
      @info "LimitOffset:getTotalResponse", @details({params: params, response: response.toJSON(), body: body})
      @extractTotalFromResponse(response, body)

  readPage: (limit, offset) ->
    params = @getPageParams(limit, offset)
    @info "LimitOffset:readPageRequest", @details({params: params})
    @getPageRequest(params).bind(@)
    .spread (response, body) ->
      @verbose "LimitOffset:readPageResponse", @details({params: params, response: response.toJSON(), body: body})
      @out.write(object) for object in body
      @progressBarIncCurrent(body.length)
      @count += body.length
      [response, body]

module.exports = LimitOffset