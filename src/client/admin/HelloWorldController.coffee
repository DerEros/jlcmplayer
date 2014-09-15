console.log(@app)

@app.controller 'HelloWorldController',
  class HelloWorldController
    @$inject = [ '$scope' ]

    constructor: (@scope) ->
      @scope.chars = [ 'h', 'e', 'l', 'o' ]
