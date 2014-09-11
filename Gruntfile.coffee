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
                  )

  grunt.loadNpmTasks('grunt-contrib-coffee')
