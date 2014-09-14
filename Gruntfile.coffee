module.exports = (grunt) ->
  grunt.initConfig(
    pkg: grunt.file.readJSON('package.json')

    clean:
      all:
        [ 'target/' ]

    coffee:
      src:
        expand: true
        cwd: 'src'
        src: [ '**/*.coffee' ]
        dest: 'target/'
        ext: '.js'

    concat:
      options:
        separator: ';'

      admin:
        src: [ 'target/client/admin/**/*.js' ]
        dest: 'target/client/admin/admin.js'

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

      client:
        files: [
          {
            expand: true
            cwd: 'target/client/admin/'
            src: 'admin.js'
            dest: 'target/server/public/'
          },
          {
            src: 'src/client/admin/index.html'
            dest: 'target/server/public/admin.html'
          }
        ]
  )

  grunt.registerTask('default', [ 'clean', 'coffee', 'concat', 'copy' ])

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-clean')
