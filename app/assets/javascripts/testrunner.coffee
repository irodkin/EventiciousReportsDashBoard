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
  $('.list-group-item-info').click ->
    active = $(this).siblings('.active')[0]
    $(active).removeClass('active')
    $(this).addClass('active')

$ ->
  $('.toggle').toggles({
    drag: true,
    click: true,
    text: {
      on: 'auto',
      off: "manual"
    },
    on: true,
    animate: 250,
    easing: 'swing',
    checkbox: null,
    clicker: null,
    width: 65,
    height: 20
    })

$ ->
  $('.toggle').click ->
    toggle = $(this).data('toggles')
    if $(toggle).attr("active")
      $('#appId').fadeOut(300)
    else
      $('#appId').fadeIn(500)



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
        $('#current_job').text(response['job'])
        $('#server .list-group-item-info').removeClass('active')
        $("#server .#{response['server']}").addClass('active')
        if params['rerun'] == 'true'
          $('.toggle').toggles(false)
          $('#appId').fadeIn(500)
        $('.activeDevice').removeClass("activeDevice")
        $("##{response['platform']}").addClass('activeDevice')
        $('#branch').val(response['branch'])
        $('#appType .list-group-item-info').removeClass('active')
        $("#appType ##{response['app_type']}").addClass('active')
        $('#appId').val(response['appid'])
        $('#suite .list-group-item-info').removeClass('active')
        $("#suite .#{response['suite']}").addClass('active')
        getTest(response['suite'])
  else
    getTest($('#suite .active').text())

$ ->
  $('#suite .list-group-item-info').click ->
    getTest($(this).text())

$ ->
  $('#server .list-group-item-info').click ->
    server = $(this).text()
    appType = $('#appType .active').attr('id')
    switch server
      when "Production"
        switch appType
          when "Single" then $('#appId').val('4193 or 4330')
          when "Multi" then $('#appId').val('4304 or 4331')
          when "Pin" then $('#appId').val('4312 or 4332')
      when "Test"
        switch appType
          when "Single" then $('#appId').val('4389 or 4452')
          when "Multi" then $('#appId').val('app is missing')
          when "Pin" then $('#appId').val('app is missing')

$ ->
  $('#appType .list-group-item-info').click ->
    appType = $(this).attr('id')
    server = $('#server .active').text()
    switch appType
      when "Single"
        switch server
          when "Production" then $('#appId').val('4193 or 4330')
          when "Test" then $('#appId').val('4389 or 4452')
      when "Multi"
        switch server
          when "Production" then $('#appId').val('4304 or 4331')
          when "Test" then $('#appId').val('app is missing')
      when "Pin"
        switch server
          when "Production" then $('#appId').val('4312 or 4332')
          when "Test" then $('#appId').val('app is missing')

$ ->
  $('#loginButton').click ->
    if $('#loginButton').hasClass('disabled')
      $('#username').addClass('empty')
      $('#password').addClass('empty')
    else
      login($('#username').val(), $('#password').val())
      $('#login').modal('hide')

$ ->
  $('.availableDevices span.label').click ->
      $('.activeDevice').removeClass("activeDevice")
      $(this).addClass("activeDevice")

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
      platform = $('.activeDevice').attr('id')
      appType = $('#appType .active').attr('id')
      branch  = $('#branch').val()
      if $(toggle).attr('active')
        appId = 0
      else
        appId = $('#appId').val()
      suite = $('#suite .active').text()
      tests = $('.test-active')
      testsArray = []
      $.each tests, (e) -> testsArray.push("@" + $(tests[e]).text())
      params = getParams()
      if params['rerun'] == 'true'
        rerun = true
        report_id = params['report_id']
      else
        rerun = false
        report_id = null
      testRun = {
        job: job
        server: server
        platform: platform
        branch: branch
        appType: appType
        appId: appId
        suite: suite
        tests: testsArray
        username: username.toString()
        password: password.toString()
        rerun: rerun
        report_id: report_id
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
