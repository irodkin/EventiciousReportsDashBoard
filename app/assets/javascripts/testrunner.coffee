# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

readCookie = (name) ->
   nameEQ = name + "="
   ca = document.cookie.split(";")
   console.log ca
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

activeDevices = () ->
  $.ajax
    url: 'api/testrun/activeDevices'
    type: 'GET'
    dataType: 'json'
    success: (response) ->
      $('#iPhone').removeClass("label-success label-danger label-warning")
      $('#Nexus4').removeClass("label-success label-danger label-warning")
      $('#Nexus7').removeClass("label-success label-danger label-warning")
      if response["iPhone"]
        $('#iPhone').addClass("label-success")
      else
        $('#iPhone').addClass("label-danger")

      if response["android"]["nexus4"]
        $('#Nexus4').addClass("label-success")
      else
        $('#Nexus4').addClass("label-danger")

      if response["android"]["nexus7"]
        $('#Nexus7').addClass("label-success")
      else
        $('#Nexus7').addClass("label-danger")
      $('#check').button('reset')


$ ->
  activeDevices()

$ ->
  $('.select-job').click ->
    $('#current_job').text($(this).text())

$ ->
  $('#addJob').click ->
    $('#addJobContainer').modal('show')

$ ->
  $('#addJobButton').click ->
     addJob = {
     title: $('#jobName').val()
     }
     $.ajax
        url: 'api/testrun/createJob'
        type: 'POST'
        dataType: 'json'
        data: addJob
        error: () ->
          alert "error!"
        success: (response) ->
          $('#addJobContainer').modal('hide')
          $('.dropdown-menu').append('<li><a class="select-job">' + response['title'] + '</a></li>')

$ ->
  $('#singIn').click ->
    $('#login').modal('show')

$ ->
  if $('#username').val() == '' || $('#password').val() == ''
    $('#loginButton').addClass('disabled')
  $('#username').change ->
    $('#username').removeClass('empty')
    unless $('#password').val() == ''
      $('#loginButton').removeClass('disabled')
  $('#password').change ->
    $('#password').removeClass('empty')
    unless $('#password').val() == ''
      $('#loginButton').removeClass('disabled')


$ ->
  setInterval(activeDevices, 10000)

$ ->
  $('#check').click ->
    $(this).button('loading')
    activeDevices()


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

getParams = ->
  query = window.location.search.substring(1)
  raw_vars = query.split("&")

  params = {}

  for v in raw_vars
    [key, val] = v.split("=")
    params[key] = decodeURIComponent(val)

  params

console.log(getParams())

$ ->
  $('#suite .list-group-item-info').click ->
    if ($(this).text() == 'MultiSmoke')
      if ($('#server .active').text() == 'Production')
        $('#appId').val('4304');
      else
        $('#appId').val('test');
    else
      if ($('#server .active').text() == 'Production')
        $('#appId').val('4193');
      else
        $('#appId').val('4389');

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
    $.ajax
      url: 'testrunner/tests'
      type: 'GET'
      dataType: 'html'
      data: suite: $('#suite .active').text()
      success: (response) ->
        $('#tests').html(response)

$ ->
  $('#server .list-group-item-info').click ->
    server = $(this).text()
    suite = $('#suite .active').text()
    if (suite == 'MultiBigSmoke')
      if (server == 'Production')
        $('#appId').val('4304');
      else
        $('#appId').val('test');
    else
      if (server == 'Production')
        $('#appId').val('4193');
      else
        $('#appId').val('4389');


$ ->
  $('#platform .list-group-item-info').click ->
    platform = $(this).text()
    if (platform == 'Android')
      $('#devices').collapse('show')
    else
      $('#devices').collapse('hide')


$ ->
  $('#loginButton').click ->
    if $('#loginButton').hasClass('disabled')
      $('#username').addClass('empty')
      $('#password').addClass('empty')
    else
      login($('#username').val(), $('#password').val())
      $('#login').modal('hide')


$ ->
  $('#run').click ->
    username = readCookie("username")
    password = readCookie("password")
    if username.toString() == '' || password.toString() == ''
      $('#login').modal('show')
    else
      $('.bg_layer').fadeIn(1200)
      $('.ajaxBusy').fadeIn(700)
      job = $('#current_job').text()
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
        job: job
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
        success: (response) ->
          $('.ajaxBusy').fadeOut(200)
          $('.bg_layer').fadeOut(500)
          $('.buildNumber').text(response['build'])
          setTimeout (-> $('.alert-success').fadeIn(700)), 700
          setTimeout (-> $('.alert-success').fadeOut(700)), 5000

$ ->
  $('#addSuite').click ->
    $('#SuitesEdit').modal("show")
    $.ajax
      url: 'testrunner/add_feature'
      type: 'GET'
      dataType: 'html'
      success: (response) ->
        $('#suitemodalbody').html(response)

$ ->
  $('#get_tests').click ->
    find = $('#find_tests').val()
    $.ajax
      url: 'api/scenarioparser/get_tests'
      type: 'GET'
      dataType: 'json'
      data: suite: find

$ ->
  $('.feature').click ->
      active = $(this).siblings('.active')[0]
      $(active).removeClass('active')
      $(this).addClass('active')
      suite = $(this).text()
      $.ajax
        url: 'testrunner/get_scenario_of_feature'
        type: 'GET'
        dataType: 'html'
        data: suite: suite
        success: (response) ->
          $('.test_container').html(response)
