nock      = require 'nock'

googleApisUrl = 'https://www.googleapis.com/'

class GoogleApisMock
  #Constants
  USER_INFO: /oauth2\/v2\/userinfo.*/
  CAL_EVENTS: /calendar\/v3\/calendars\/primary\/events.*/

  #Methods
  constructor: ()->
    afterEach (done) ->
      nock.cleanAll();
      done()

  get: (type) ->
    @type = type
    return @

  andReply: (response) ->
    loadNock(@type, response)

  andReplyFromFile: (filename) ->
    response = require './json/'+filename
    loadNock(@type, response)

#Private Methods
loadNock = (type, response) ->
  before (done) ->
    nock(googleApisUrl)
    .get(type)
    .reply(200, response)
    done()

module.exports = GoogleApisMock