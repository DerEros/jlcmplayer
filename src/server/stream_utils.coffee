# General purpose utility functionality related to streams

fs = require( 'fs' )
_s = require( 'highland' )

# Small wrapper for the fs.exists function to make it use the usual callback format (err, data) so it can be used with
# Highland streams more easily
_nodebackExists = ( name, cb ) ->
  fs.exists( name, ( exists ) ->
    cb( null, exists )
  )

# Streaming wrapper for fs.exists
_checkExists = _s.wrapCallback( _nodebackExists )

# Logs an error to the given logger and than pushes it back into the stream for additional processing
_logAndForwardError = _s.curry( (logger, text, error, push) ->
  logger.error(text, error)
  push(error)
)

# Creates a stream that contains the given error object on the error side. Useful for testing error handling
_errorStream = ( err ) -> _s( ( push ) -> push( err ) )

module.exports = {
  nodebackExists: _nodebackExists
  checkExists: _checkExists
  logAndForwardError: _logAndForwardError
  errorStream: _errorStream
}
