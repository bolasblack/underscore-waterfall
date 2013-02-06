module.exports = function(grunt) {
  grunt.initConfig({
    watch: {
      files: ['test/spec/tests.coffee', 'src/underscore.waterfall.coffee'],
      tasks: ['coffee', 'test']
    },
    coffee: {
      compile: {
        files: {
          'test/js/tests.js': 'test/spec/tests.coffee',
          'lib/underscore.waterfall.js': 'src/underscore.waterfall.coffee'
        }
      }
    },
    mocha: {
      all: {
        src: "test/tests.html",
        options: {
          run: true
        }
      }
    }
  })

  grunt.loadNpmTasks('grunt-mocha')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.task.registerTask('test', ['mocha'])
  grunt.task.registerTask('default', 'mocha')
}
