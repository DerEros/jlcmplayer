@app.config(
  class Routing
    @$inject = [ "$routeProvider" ]

    constructor: ($routeProvider) ->
      $routeProvider.when "/lists",
        templateUrl: "views/playlists.html"
        controller: "PlaylistController as ctrl"
)
