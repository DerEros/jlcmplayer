@app.controller 'SourcesController',
  class SourcesController
    @$inject = [ '$scope' ]

    constructor: ($scope) ->
      $scope.text = "Sources"
