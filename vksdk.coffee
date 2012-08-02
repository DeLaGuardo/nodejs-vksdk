###
@author delaguardo@gmail.com
@see https://github.com/DeLaGuardo/nodejs-vksdk
###
module.exports =
  init: (appID, appSecret) ->
    @appID = appID
    @appSecret = appSecret
    @crypto = require("crypto")
    @http = require("http")

  request: (method, params, callback) ->
    @callback = callback
    params.api_id = @appID
    params.v = "3.0"
    params.method = method
    params.timestamp = new Date().getTime()
    params.format = "json"
    params.random = Math.floor(Math.random() * 9999)
    params = @_sortObjectByKey(params)
    sig = ""
    for key of params
      sig = sig + key + "=" + params[key]
    sig = sig + @appSecret
    params.sig = @crypto.createHash("md5").update(sig).digest("hex")
    requestArray = []
    for key of params
      requestArray.push key + "=" + params[key]
    requestString = @_implode("&", requestArray)
    options =
      host: "api.vk.com"
      port: 80
      path: "/api.php?" + requestString

    @http.get options, (res) ->
      apiResponse = ""
      res.setEncoding "utf8"
      res.on "data", (chunk) ->
        apiResponse += chunk

      res.on "end", ->
        o = JSON.parse(apiResponse)
        module.exports.callback o



  _implode: implode = (glue, pieces) ->
    (if (pieces instanceof Array) then pieces.join(glue) else pieces)

  _sortObjectByKey: (o) ->
    sorted = {}
    key = undefined
    a = []
    for key of o
      a.push key  if o.hasOwnProperty(key)
    a.sort()
    key = 0
    while key < a.length
      sorted[a[key]] = o[a[key]]
      key++
    sorted