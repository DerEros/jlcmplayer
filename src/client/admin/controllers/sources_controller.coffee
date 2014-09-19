@app.controller 'SourcesController',
  class SourcesController
    @$inject = [ '$scope', 'Restangular' ]

    constructor: ( @$scope, Restangular ) ->
      Restangular.all( 'admin' ).all( 'sources' ).getList().then( (list) => @sources = list )

      @resetEditing()

    addSource: ->
      @cancelEdit()

      sources = @sources || []
      sources.unshift( new Source( "New", "/", false ) )

      @edit(sources[0])

      # TODO: tell the backend

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
      @sources = _.filter( @sources, (s) -> s != source )
      # TODO: tell the backend

    save: ->
      @resetEditing()
      # TODO: tell the backend

    resetEditing: ->
      @currentlyEditing = "none"
      @sourceOldValues = "none"
