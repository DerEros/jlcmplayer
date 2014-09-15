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
        src: [ 'target/client/admin/index.js', 'target/client/admin/**/*.js' ]
        dest: 'target/client/admin/admin.js'

    bower_concat:
      all:
        dest: 'target/client/3rdparty.js'
        include: [
          'lodash'
          'highland'
          'angular'
          'angular-route'
          'mobile-angular-ui'
        ]

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
          },
          {
            src: 'target/client/3rdparty.js'
            dest: 'target/server/public/3rdparty.js'
          },
          {
            expand: true
            cwd: 'bower_components/mobile-angular-ui/dist/css/'
            src: [ 'mobile-angular-ui-base.min.css'
              'mobile-angular-ui-hover.min.css'
              'mobile-angular-ui-desktop.min.css'
            ]
            dest: 'target/server/public/'
          },
          {
            expand: true
            cwd: 'bower_components/mobile-angular-ui/dist'
            src: 'fonts/*'
            dest: 'target/server/public/'
          }
        ]
  )

  grunt.registerTask('default', [ 'clean', 'coffee', 'concat', 'bower_concat', 'copy' ])

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-bower-concat')
  grunt.loadNpmTasks('grunt-contrib-clean')
