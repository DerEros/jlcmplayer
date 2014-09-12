module.exports = (grunt) ->
  grunt.initConfig(
    pkg: grunt.file.readJSON('package.json')

    coffee:
      src:
        expand: true
        cwd: 'src'
        src: [ '**/*.coffee' ]
        dest: 'target/'
        ext: '.js'

    copy:
      conf:
        files: [
          {
            expand: true
            cwd: 'src/conf'
            src: '**'
            dest: 'target/server/conf/'
          }
        ]
  )

  grunt.registerTask('default', [ 'coffee', 'copy' ])

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-copy')
