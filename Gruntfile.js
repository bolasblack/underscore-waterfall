module.exports = function(grunt) {
  grunt.initConfig({
    watch: {
      files: ['test/spec/tests.coffee', 'src/underscore.waterfall.coffee'],
      tasks: ["mocha"]
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
  grunt.task.registerTask('test', ['mocha'])
  grunt.task.registerTask('default', 'mocha')
}
