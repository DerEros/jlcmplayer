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

# Transforms a function that takes a node-style callback (function (err, data)) into a stream. Similar to what
# Highland wrapCallback() does but keeps the self/this ptr and does the call to the wrapped function too
_streamify = ( self, f, args... ) ->
  _s( ( push ) ->
    callback = ( err, data ) ->
      if err
        push( err )
      else
        push( null, data )
      push( null, nil )

    f.apply( self, args.concat( [ callback ] ) )
  )


module.exports = {
  nodebackExists: _nodebackExists
  checkExists: _checkExists
  logAndForwardError: _logAndForwardError
  errorStream: _errorStream
  streamify: _streamify
}
