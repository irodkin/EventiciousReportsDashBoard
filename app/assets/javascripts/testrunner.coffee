# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

readCookie = (name) ->
   nameEQ = name + "="
   ca = document.cookie.split(";")
   i = 0
   while i < ca.length
     c = ca[i]
     c = c.substring(1, c.length)  while c.charAt(0) is " "
     return c.substring(nameEQ.length, c.length).replace(/"/g, '')  if c.indexOf(nameEQ) is 0
     i++
   ca

setCookie = (cookieName, cookieValue) ->
   day = 1000 * 60 * 60  * 24
   today = new Date()
   expire = today + day
   document.cookie = cookieName + "=" + escape(cookieValue) + ";expires=" + (20 * expire).toString()

login = (username, password) ->
  setCookie("username", username)
  setCookie("password", password)

$ ->
  $('.select-platform').click ->
    button_title = $('#select-platform')
    platform = $(this).text()
    $(button_title).text(platform)

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
      $('#devices').collapse('show')
    else
      $('#devices').collapse('hide')


$ ->
  $('#loginButton').click ->
    login($('#username').val(), $('#password').val())
    $('#login').modal('hide')


$ ->
  $('#run').click ->
    username = readCookie("username")
    password = readCookie("password")
    console.log username.toString() == ''
    console.log password.toString() == ''
    if username.toString() == '' || password.toString() == ''
      $('#login').modal('show')
    else
      $('.bg_layer').fadeIn(1200)
      $('.ajaxBusy').fadeIn(700)
      server = $('#server .active').text()
      platform = $('#platform .active').text()
      device =$('#devices .active').text()
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
        username: username.toString()
        password: password.toString()
      }
      $.ajax
        url: 'api/testrun/run'
        type: 'POST'
        dataType: 'json'
        data: testRun
        error: ->
          $('.ajaxBusy').fadeOut(200)
          $('.bg_layer').fadeOut(500)
          setTimeout (-> $('.alert-danger').fadeIn(700)), 700
          setTimeout (-> $('.alert-danger').fadeOut(700)), 5000
        success: () ->
          $('.ajaxBusy').fadeOut(200)
          $('.bg_layer').fadeOut(500)
          setTimeout (-> $('.alert-success').fadeIn(700)), 700
          setTimeout (-> $('.alert-success').fadeOut(700)), 5000