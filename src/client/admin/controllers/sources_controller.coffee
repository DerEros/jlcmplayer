@app.controller 'SourcesController',
  class SourcesController
    @$inject = [ '$scope', 'Restangular' ]

    constructor: ( $scope, Restangular ) ->
      Restangular.all( 'admin' ).all( 'sources' ).getList().then( (list) -> $scope.sources = list )
