log4js = require('log4js')
_s = require('highland')
streamUtils = require('./stream_utils')

# Some default locations where to look for the log4js configuration
configFiles = [
  "#{__dirname}/conf/log4js.json"
  "#{__dirname}/log4js.json"
  "#{__dirname}/conf/log4js.conf"
  "#{__dirname}/log4js.conf"
]

# In case we cannot find any configuration file
defaultConfig = {
  appenders: [
    { type: "console" }
  ],
  replaceConsole: true
}

module.exports = {
  #
  # Configure Log4JS using the first configuration found. Callback is there to ensure that the caller starts running
  # after Log4JS has been configured. Configuration happens asynchronously and takes a few milliseconds. In this time
  # you might not want to issue log statements.
  #
  config: (onEndCB) ->
    console.log("-- ", onEndCB)
    _s(configFiles).flatFilter(streamUtils.checkExists)
                   .otherwise([ defaultConfig ])
                   .head()
                   .map(log4js.configure)
                   .on('end', onEndCB)
                   .errors( -> console.error("Configuring logger failed"))
                   .each( -> console.log("Log4JS successfully configured"))
}
