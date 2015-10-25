# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
server = null
host = null
$ ->
  $('.select').click ->
    what = $(this).attr('name')
    server = $(this).text() if what == 'Server'
    host = $(this).text() if what == 'Host'
    console.log server, host
