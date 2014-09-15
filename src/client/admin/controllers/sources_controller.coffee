@app.controller 'SourcesController',
  class SourcesController
    @$inject = [ '$scope' ]

    constructor: ($scope) ->
      $scope.source = new Source("foo", "/foo/bar", true)
      $scope.text = JSON.stringify($scope.source)

      $scope.sources = [
        new Source("foo", "/foo", true)
        new Source("bar", "/bar", false)
        new Source("baz", "/baz", false)
        new Source("gak", "/gak", true)
      ]
