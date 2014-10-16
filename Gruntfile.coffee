module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    webfont:
      icons:
        src: 'dev/icons/*.svg'
        dest: 'public/icons'
        destCss: 'dev/stylus'
        options:
          font: 'icons'
          rename: (name) ->
            class_name = name.toLowerCase()
            class_name = class_name.replace("i_", "")
            remove_path = class_name.lastIndexOf('/')
            class_name = class_name.substr((remove_path + 1))
            return class_name
          syntax: "bootstrap"
          hashes: false
          engine:"node"
          templateOptions:
            baseClass: "icon"
            classPrefix: "icon-"
            mixinPrefix: "icon-"
          stylesheet: "styl"
          relativeFontPath: "/icons"
          embed: ['woff', 'ttf', 'svg', 'eot']

    concat:
      dist:
        src: [
          'bower_components/jquery/dist/jquery.js'
          'bower_components/angular/angular.js'
          'bower_components/angular-sanitize/angular-sanitize.js'
          'bower_components/hammerjs/hammer.js'
          'bower_components/jquery-hammerjs/jquery.hammer.js'
          'bower_components/google-maps-utility-library-v3/markerwithlabel/src/markerwithlabel_packed.js',
          'bower_components/jquery-easing-original/jquery.easing.1.3.min.js',
          'bower_components/jquery.transit/jquery.transit.js',
          'bower_components/kaymak.js/kay.min.js',
          ]
        dest: 'public/javascripts/plugins.js'

    coffee:
      compile:
        options:
          bare: true
        files:
          'public/javascripts/app.js': [
            'dev/coffee/*.coffee',
            'dev/coffee/*/*.coffee',
            'dev/coffee/directives/*/*.coffee',
            'dev/coffee/modules/*/*.coffee',
            'dev/coffee/modules/*/**/*.coffee'
          ]


    stylus:
      compile:
        options:
          compress: false
          paths: ['dev/stylus/']

        files: [
          'public/stylesheets/app.css': 'dev/stylus/app.styl'
        ]

    jade:
      templates:
        files: [{ 
          expand: true
          src: "**/*.jade"
          dest: "public/"
          cwd: "dev/coffee"
          ext: ".html"
        }]

        options:
          compileDebug: true


    copy:
      images:
        files: [
          {expand: true, cwd: 'dev/images', src: ['**/*'], dest: 'public/images'}, {expand: true, cwd: 'dev/videos', src: ['**/*'], dest: 'public/videos'}
        ]

    watch:
      coffee:
        files: ['dev/coffee/**/*.coffee']
        tasks: ['coffee']

      stylus:
        files: ['dev/stylus/**/*.styl']
        tasks: ['stylus']

      jadeTemplates:
        files: ['dev/coffee/**/*.jade']
        tasks: ['jade:templates']

      images:
        files: ['dev/images/**/*']
        tasks: ['copy:images']

      node_files:
        files: [
          'app.coffee',
          'routes/**/*.coffee',
          'bin/*',
          'locales/*'
        ]
        tasks: ['develop']
        options:
          nospawn: true

    develop:
      server:
        file: 'bin/www.coffee'
        cmd: 'coffee'

    notify:
      watch:
        options:
          title:"Hello"
          message:"All files are compiled"

    cssmin:
      minify:
          expand: true
          cwd: 'public/stylesheets/'
          src: ['*.css', '!*.min.css']
          dest: 'public/stylesheets/'
          ext: '.css'

    uglify:
      scripts:
        options:
          mangle: false
        files:
          'public/javascripts/app.js': ['public/javascripts/app.js']
      plugins:
        options:
          mangle: false
        files:
          'public/javascripts/plugins.js': ['public/javascripts/plugins.js']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-develop'
  grunt.loadNpmTasks 'grunt-webfont'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  
  grunt.registerTask 'default', [
    'notify',
    'webfont',
    'coffee',
    'stylus',
    'jade:templates',
    'copy:images',
    'concat',
    'develop',
    'watch'
  ]

  grunt.registerTask 'production', [
    'webfont',
    'coffee',
    'stylus',
    'jade:templates',
    'copy:images',
    'concat'
    'uglify'
    'cssmin'
  ]
