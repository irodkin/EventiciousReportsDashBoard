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

getTest = (suite) ->
  $.ajax
    url: 'testrunner/tests'
    type: 'GET'
    dataType: 'html'
    data:
      suite: suite
    success: (response) ->
      $('#tests').html(response)


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

$ ->
  $('.toggle').toggles({
    drag: true,
    click: true,
    text: {
      on: 'build',
      off: "don't build"
    },
    on: true,
    animate: 250,
    easing: 'swing',
    checkbox: null,
    clicker: null,
    width: 90,
    height: 25
    })



getParams = ->
  query = window.location.search.substring(1)
  raw_vars = query.split("&")

  params = {}

  for v in raw_vars
    [key, val] = v.split("=")
    params[key] = decodeURIComponent(val)

  params

$ ->
  params = getParams()
  if params['rerun'] == 'true' || params['reply'] == 'true'
    $.ajax
      url: 'testrunner/reply_run_params'
      type: 'GET'
      dataType: 'json'
      data:
        report_id: params['report_id']
      error: () ->
        console.log "something going wrong"
      success: (response) ->
        $('#server .list-group-item-info').removeClass('active')
        $("#server .#{response['server']}").addClass('active')
        if params['rerun'] == 'true'
          $('.toggle').toggles(false)
        $('.activeDevice').removeClass("activeDevice")
        if response['platform'] == 'Android'
          $("##{response['device']}").addClass('activeDevice')
        else
          $('#iPhone').addClass('activeDevice')
        $('#branch').val(response['branch'])
        $('#appId').val(response['appid'])
        $('#suite .list-group-item-info').removeClass('active')
        $("#suite .#{response['suite']}").addClass('active')
        getTest(response['suite'])
  else
    getTest($('#suite .active').text())

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
    getTest($(this).text())

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
  $('#Nexus4').tooltip({title: "<strong>go to <a href=\"http://192.168.162.34:7100/#!/control/04d228289809504a\" target=\"blank\">stf farm</a> to drive that device</strong>", html: true, delay: {"hide": 700 }})
  $('#Nexus7').tooltip({title: "<strong>go to <a href=\"http://192.168.162.34:7100/#!/control/015d2578a21c1403\" target=\"blank\">stf farm</a> to drive that device</strong>", html: true, delay: {"hide": 700 }})

$ ->
  $('.availableDevices span.label').click ->
    console.log $(this).attr('class')
    console.log (' ' + $(this).attr('class') + ' ').indexOf(' ' + "label" + ' ')
    console.log ($(this).attr('class')).indexOf("label-success")
    console.log (' ' + $(this).attr('class') + ' ').indexOf(' ' + "label-success" + ' ')
    if (' ' + $(this).className + ' ').indexOf(' ' + "label-danger" + ' ') > -1
      $('.activeDevice').removeClass("activeDevice")
      $(this).addClass("activeDevice")
      console.log "1"
    else
      console.log "2"

$ ->
  $('#run').click ->
    username = readCookie("username")
    password = readCookie("password")
    toggle = $('.toggle').data('toggles')
    if username.toString() == '' || password.toString() == ''
      $('#login').modal('show')
    else
      $('.bg_layer').fadeIn(1200)
      $('.ajaxBusy').fadeIn(700)
      job = $('#current_job').text()
      server = $('#server .active').text()
      platform = $('.activeDevice').attr('platformtype')
      if platform == 'Android'
        device = $('.activeDevice').attr('id')
      else
        device = "Nexus4"
      branch  = $('#branch').val()
      appId = $('#appId').val()
      suite = $('#suite .active').text()
      tests = $('.test-active')
      buildAgain = $(toggle).attr("active")
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
        buildAgain: buildAgain
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
