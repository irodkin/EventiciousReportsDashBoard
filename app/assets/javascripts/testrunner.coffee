# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

readCookie = (name) ->
  ca = document.cookie.split("; ")
  #console.log ca
  i = 0
  ca_l = ca.length
  while i < ca_l && !ca[i].startsWith(name)
    i++
  if i == ca_l
    return null
  else
    return ca[i].match(/=(.+)/)[1]

setCookie = (cookieName, cookieValue) ->
  day = 1000 * 60 * 60  * 24
  today = new Date()
  expire = today + day
  document.cookie = cookieName + "=" + escape(cookieValue) + ";expires=" + (20 * expire).toString()

login = (username, password) ->
  setCookie("username", username)
  setCookie("password", password)
  $('#signIn').text("Logged In")

getTest = (suite) ->
  $.ajax
    url: 'testrunner/tests'
    type: 'GET'
    dataType: 'html'
    data:
      suite: suite
    success: (response) ->
      $('#tests').html(response)

getParams = ->
  query = window.location.search.substring(1)
  raw_vars = query.split("&")
  params = {}
  for v in raw_vars
    [key, val] = v.split("=")
    params[key] = decodeURIComponent(val)
  params

run_after_login = ->
  #console.log("inside run_after_login")
  $('#run').trigger("click")
  #console.log("removing run_after_login")
  $('#loginButton').off("click", run_after_login)

getBuilds = ->
  $.ajax
    url: 'testrunner/builds'
    type: 'GET'
    dataType: 'html'
    data: job: $('#current_job').text()
    success: (response) ->
      $('#builds').html(response)

$(document).on "page:change", ->

  $('.select-job').click ->
    $('#current_job').text($(this).text())
    getBuilds()

  $('#addJob').click ->
    $('#addJobContainer').modal('show')

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

  $('#signIn').click ->
    $('#login').modal('show')

  if readCookie("username") && readCookie("password")
    $('#signIn').text("Logged In")

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

  $('.list-group-item-info').click ->
    $(this).siblings('.active').removeClass('active')
    $(this).addClass('active')

  $('#platform span.label').click ->
      $('.activeDevice').removeClass("activeDevice")
      $(this).addClass("activeDevice")

  $('#appId-toggle').toggles({
    drag: false,
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

  $('#appId-toggle').click ->
    toggle = $(this).data('toggles')
    if $(toggle).attr("active")
      $('#appId').fadeOut(300)
      #$('#appType').fadeIn(500)
      #$('#appType').prev().fadeIn(500)
    else
      $('#appId').fadeIn(500)
      #$('#appType').fadeOut(300)
      #$('#appType').prev().fadeOut(300)

  $('#rebuildApp-toggle').toggles({
    drag: false,
    click: true,
    text: {
      on: 'yes',
      off: "no"
    },
    on: true,
    animate: 250,
    easing: 'swing',
    checkbox: null,
    clicker: null,
    width: 65,
    height: 20
    })

  if window.location.href.includes("/testrunner")
    getBuilds()
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
          getBuilds()
          $("#server .#{response['server']}").trigger('click')
          if params['rerun'] == 'true'
            $('#appId-toggle').toggles(false)
            $('#appId').fadeIn(500)
            $('#rebuildApp-toggle').toggles(false)
          $("##{response['platform']}").trigger('click')
          $('#branch').val(response['branch'])
          $("#appType ##{response['app_type']}").trigger('click')
          $("#locale ##{response['locale']}").trigger('click')
          $('#appId').val(response['appid'])
          $("#suite .#{response['suite']}").trigger('click')
          getTest(response['suite'])
    else
      getTest($('#suite .active').text())

  $('#suite .list-group-item-info').click ->
    getTest($(this).text())

  $('#server .list-group-item-info').click ->
    server = $(this).text()
    locale = $('#locale .active').attr('id')
    switch server
      when "Production"
        switch locale
          when "ru" then $('#appId').val('4193 or 4330')
          when "en" then $('#appId').val('4331 or 4332')
      when "Test"
        switch locale
          when "ru" then $('#appId').val('4389 or 4452')
          when "en" then $('#appId').val('4454 or 4455')

  $('#locale .list-group-item-info').click ->
    locale = $(this).attr('id')
    server = $('#server .active').text()
    switch locale
      when "ru"
        switch server
          when "Production" then $('#appId').val('4193 or 4330')
          when "Test" then $('#appId').val('4389 or 4452')
      when "en"
        switch server
          when "Production" then $('#appId').val('4331 or 4332')
          when "Test" then $('#appId').val('4454 or 4455')

  $('#loginButton').click ->
    if $('#loginButton').hasClass('disabled')
      $('#username').addClass('empty')
      $('#password').addClass('empty')
    else
      login($('#username').val(), $('#password').val())
      $('#login').modal('hide')

  $('#run').click ->
    username = readCookie("username")
    password = readCookie("password")
    appId_toggle = $('#appId-toggle').data('toggles')
    rebuildApp_toggle = $('#rebuildApp-toggle').data('toggles')
    if !username || !password
      $('#login').modal('show')
      #console.log("adding run_after_login")
      $('#loginButton').on("click", run_after_login)
    else
      $('.bg_layer').fadeIn(1200)
      $('.ajaxBusy').fadeIn(700)
      job = $('#current_job').text()
      server = $('#server .active').text()
      platform = $('.activeDevice').attr('id')
      appType = $('#appType .active').attr('id')
      locale = $('#locale .active').attr('id')
      branch = $('#branch').val()
      if $(appId_toggle).attr('active')
        appId = 0
      else
        appId = $('#appId').val()
      if $(rebuildApp_toggle).attr('active')
        rebuildApp = true
      else
        rebuildApp = false
      suite = $('#suite .active').text()
      tests = $('.test-active')
      testsArray = []
      $.each tests, (e) -> testsArray.push("@" + $(tests[e]).text())
      iterations = $('#iterations').val()
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
        locale: locale
        appId: appId
        suite: suite
        tests: testsArray
        iterations: iterations
        rebuildApp: rebuildApp
        username: username
        password: password
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
          setTimeout (-> getBuilds()), 2000

  $('#addSuite').click ->
    $('#SuitesEdit').modal("show")

  $('#get_tests').click ->
    find = $('#find_tests').val()
    $.ajax
      url: 'api/scenarioparser/get_tests'
      type: 'GET'
      dataType: 'json'
      data: suite: find
