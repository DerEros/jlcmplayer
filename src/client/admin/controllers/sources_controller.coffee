@app.controller 'SourcesController',
  class SourcesController
    @$inject = [ '$scope', 'Restangular' ]

    constructor: ( @$scope, @Restangular ) ->
      @sources = []
      @busy = true
      Restangular.all( 'admin' ).all( 'sources' ).getList().then( (list) => @sources = list ).finally(@unbusy)

      @resetEditing()

    addSource: ->
      @cancelEdit()
      @sources.unshift( new Source( "New", "/", false ) )
      @edit(@sources[0])

      @busy = true
      @Restangular.all( 'admin' ).all( "sources" ).post( @sources[0] ).finally(@unbusy)

    edit: ( source ) ->
      @cancelEdit()
      @backupBeforeEdit( source )
      @currentlyEditing = source

    isBeingEdited: ( source ) -> source == @currentlyEditing

    cancelEdit: ->
      _.assign( @currentlyEditing, @sourceOldValues )
      @resetEditing()

    backupBeforeEdit: ( source ) -> @sourceOldValues = _.clone( source )

    delete: ( source ) ->
      @busy = true
      source.remove()
            .then( => @sources = _.without( @sources, source ))
            .catch( -> alert("Deleting failed") )
            .finally( @unbusy )


    save: ->
      @busy = true
      @Restangular.all( 'admin' ).all( "sources" ).post( @currentlyEditing )
                  .then( @resetEditing )
                  .catch( @cancelEdit )
                  .finally( @unbusy )

    resetEditing: =>
      @currentlyEditing = "none"
      @sourceOldValues = "none"

    unbusy: =>
      @busy = false
