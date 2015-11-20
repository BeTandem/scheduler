module.exports = (grunt) ->
  grunt.initConfig
    nodemon:
      dev:
        script: 'server/index.js'
  require('load-grunt-tasks') grunt
  grunt.registerTask 'develop', [
    'nodemon'
  ]