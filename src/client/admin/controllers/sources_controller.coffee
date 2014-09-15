@app.controller 'SourcesController',
  class SourcesController
    @$inject = [ '$scope' ]

    constructor: ($scope) ->
      $scope.source = new Source("foo", "/foo/bar", true)
      $scope.text = JSON.stringify($scope.source)
