@app.config(
  class Routing
    @$inject = [ "$routeProvider" ]

    constructor: ($routeProvider) ->
      $routeProvider.when "/sources",
        templateUrl: "views/sources.html"
        controller: "SourcesController as ctrl"

      $routeProvider.when "/lists",
        templateUrl: "views/lists.html"
        controller: "ListsController as ctrl"
)
