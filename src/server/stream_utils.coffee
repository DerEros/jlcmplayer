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

module.exports = {
  nodebackExists: _nodebackExists
  checkExists: _checkExists
}
