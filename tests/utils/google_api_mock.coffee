nock      = require 'nock'

googleApisUrl = 'https://www.googleapis.com/'
googleAccountsUrl = 'https://accounts.google.com/'

POST = 'post'
GET = 'get'


class GoogleApisMock
  #Constants
  USER_INFO: /oauth2\/v2\/userinfo.*/
  TIMEZONE: /users\/me\/settings\/timezone.*/
  CAL_EVENTS: /calendar\/v3\/calendars\/primary\/events.*/
  AUTH: /o\/oauth2\/token.*/
  CAL_LIST: /calendar\/v3\/users\/me\/calendarList.*/
  FREEBUSY: /calendar\/v3\/freeBusy.*/

  #Methods
  constructor: ()->
    after (done) ->
      nock.cleanAll();
      done()

  get: (type) ->
    @type = type
    @url = if @type == @AUTH then googleAccountsUrl else googleApisUrl
    @httpProtocol = GET
    return @

  post: (type) ->
    @type = type
    @url = if @type == @AUTH then googleAccountsUrl else googleApisUrl
    @httpProtocol = POST
    return @

  andRespond: (response) ->
    switch @httpProtocol
      when POST then loadPostNock(@url, @type, response)
      when GET then loadGetNock(@url, @type, response)


  andRespondFromFile: (filename) ->
    response = require './json/'+filename
    switch @httpProtocol
      when POST then loadPostNock(@url, @type, response)
      when GET then loadGetNock(@url, @type, response)

#Private Methods
loadGetNock = (url, type, response, done) ->
  nock(url)
  .get(type)
  .reply(200, response)
  if done
    done()

loadPostNock = (url, type, response, done) ->
  nock(url)
  .post(type)
  .reply(200, response)
  if done
    done()

module.exports = GoogleApisMock