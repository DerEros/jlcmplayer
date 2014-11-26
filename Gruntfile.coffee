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
        src: [ 'target/client/admin/app.js', 'target/common/**/*.js', 'target/client/admin/**/*.js' ]
        dest: 'target/client/admin/admin.js'

      player:
        src: [ 'target/client/player/app.js', 'target/common/**/*.js', 'target/client/player/**/*.js' ]
        dest: 'target/client/player/player.js'

    bower_concat:
      all:
        dest: 'target/client/3rdparty.js'
        include: [
          'lodash'
          'highland'
          'angular'
          'angular-route'
          'angular-touch'
          'mobile-angular-ui'
          'restangular'
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
            expand: true
            cwd: 'src/client/admin/'
            src: 'views/**'
            dest: 'target/server/public/'
          },
          {
            expand: true
            cwd: 'target/client/player'
            src: 'player.js'
            dest: 'target/server/public'
          },
          {
            src: 'src/client/player/index.html'
            dest: 'target/server/public/index.html'
          },
          {
            expand: true
            cwd: 'src/client/player'
            src: 'views/**'
            dest: 'target/server/public/'
          },
          {
            expand: true
            cwd: 'src/client/'
            src: 'img/**'
            dest: 'target/server/public/'
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
            dest: 'target/server/public/css/'
          },
          {
            expand: true
            cwd: 'bower_components/mobile-angular-ui/dist'
            src: 'fonts/*'
            dest: 'target/server/public/'
          }
        ]

      cache:
        files: [
          {
            src: 'src/cover_cache/amazon_secret.json'
            dest: 'target/cover_cache/amazon_secret.json'
          }
        ]
  )

  grunt.registerTask('default', [ 'clean', 'coffee', 'concat', 'bower_concat', 'copy' ])

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-bower-concat')
  grunt.loadNpmTasks('grunt-contrib-clean')
