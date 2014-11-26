@app.config(
  class RestangularConfig
    @$inject = [ "RestangularProvider" ]

    constructor: (RestangularProvider) ->
      RestangularProvider.setRestangularFields({
        id: "_id"
      })
)
