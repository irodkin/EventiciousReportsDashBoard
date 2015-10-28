# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('.select-platform').click ->
    button_title = $('#select-platform')
    platform = $(this).text()
    $(button_title).text(platform)

#$ ->
 # $('#send').click ->
   # response = {
   #   success: true
   # }
   # $.ajax
   #   url: 'api/testrun/run'
   #   type: 'POST'
   #   dataType: 'json'
   #   data: response
   #   success: (response) ->
   #     console.log response

$ ->
  $('.list-group-item-info').click ->
    active = $(this).siblings('.active')[0]
    $(active).removeClass('active')
    $(this).addClass('active')

$ ->
  $('#suite .list-group-item-info').click ->
    response = {
      suite: $(this).text()
    }
    $.ajax
      url: 'testrunner/tests'
      type: 'GET'
      dataType: 'html'
      data: response
      success: (response) ->
        $('#tests').html(response)

$ ->
  $('#server .list-group-item-info').click ->
    server = $(this).text()
    $('#appId').val('4286');
    if (server == 'Production')
      $('#appId').val('4193')
    else
      $('#appId').val('4389')


$ ->
  $('#platform .list-group-item-info').click ->
    platform = $(this).text()
    if (platform == 'Android')
      $('.dropdown').show()
    else
      $('.dropdown').hide()


$ ->
  $('#run').click ->
    $('.ajaxBusy').fadeIn(700)
    $('.bg_layer').fadeIn(1200)

    server = $('#server .active').text()
    platform = $('#platform .active').text()
    device =$('#select-platform').text()
    branch  = $('#branch').val()
    appId = $('#appId').val()
    suite = $('#suite .active').text()
    tests = $('.test-active')
    testsArray = []
    $.each tests, (e) -> testsArray.push("@" + $(tests[e]).text())

    testRun = {
      server: server
      platform: platform
      device: device
      branch: branch
      appId: appId
      suite: suite
      tests: testsArray
    }

    $.ajax
      url: 'api/testrun/run'
      type: 'POST'
      dataType: 'json'
      data: testRun
      error: ->
        $('.ajaxBusy').fadeOut(200)
        $('.bg_layer').fadeOut(500)
        $('.alert-danger').fadeIn(700)
        $('.alert-danger').fadeOut(700)
      success: () ->
        $('.ajaxBusy').fadeOut(200)
        $('.bg_layer').fadeOut(500)
        setTimeout (-> $('.alert-success').fadeIn(700)), 700
        setTimeout (-> $('.alert-success').fadeOut(700)), 5000

