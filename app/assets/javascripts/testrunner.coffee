# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
server = null
host = null
$ ->
  $('.select-server').click ->
    button_title = $('#select-server')
    server = $(this).text()
    console.log button_title.text()
    $(button_title).text(server)

$ ->
  $('#send').click ->
    response = {
      success: true
    }
    $.ajax
      url: 'api/testrun/run'
      type: 'POST'
      dataType: 'json'
      data: response
      success: (response) ->
        console.log response



$ ->
  $('.list-group-item-info').click ->
    response = {
      suite: 'BigSmoke'
    }
    $.ajax
      url: 'testrunner/tests'
      type: 'GET'
      dataType: 'html'
      data: response
      success: (response) ->
        $('#tests').html(response)

$ ->
  $('#suite ul li a').click ->
    li = $(this).parents('li')[0]
    $('#suite .active').removeClass('active')
    $(li).addClass('active')

$ ->
  $('#tests span').click ->
    $('#tests .test-active').removeClass('test-active')
    $(this).addClass('test-active')