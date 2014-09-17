@app.controller 'SourcesController',
  class SourcesController
    @$inject = [ '$scope', 'Restangular' ]

    constructor: ( @$scope, Restangular ) ->
      Restangular.all( 'admin' ).all( 'sources' ).getList().then( (list) -> $scope.sources = list )
      @$scope.addSource = _.bind(@addSource, @)

    addSource: ->
      sources = @$scope.sources || []
      sources.unshift( new Source( "New", "/", false ) )
      @$scope.sources = sources
