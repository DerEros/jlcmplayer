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

# Streaming wrapper for fs.rename
_rename = _s.wrapCallback( fs.rename )

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

# Similar to the one above but for callbacks that take three arguments
_streamify3 = ( self, f, args... ) ->
  _s( ( push ) ->
    callback = ( err, data1, data2 ) ->
      if err
        push( err )
      else
        push( null, [ data1, data2 ] )
      push( null, nil )

    f.apply( self, args.concat( [ callback ] ) )
  )


module.exports = {
  nodebackExists: _nodebackExists
  checkExists: _checkExists
  logAndForwardError: _logAndForwardError
  errorStream: _errorStream
  streamify: _streamify
  streamify3: _streamify3
}
