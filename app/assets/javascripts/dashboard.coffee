# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(".deleteButton").click ->
    current_record_tr = $(this).parents('tr')[0]
    $.ajax
      url: 'dashboard/' + $(current_record_tr).attr('recordid')
      type: 'DELETE'
      $(current_record_tr).fadeOut(700)

$ ->
  $("#refresh").click ->
      window.location.reload()
$ ->
  $(".reply").click ->
    parent_td = $(this).parents('tr')[0]
    platform = $(parent_td).children('td')[1]
    server = $(parent_td).children('td')[2]
    app = $(parent_td).children('td')[3]
    branch = $(parent_td).children('td')[4]
    suite = $(parent_td).children('td')[5]
    tests_orig = $(parent_td).children('td')[6]
    device = $(parent_td).children('td')[7]
    tests = $(tests_orig).text().split(" ")
    for i in [0..tests.length-1]
      tests[i] = tests[i].replace("@", "")
    json = {
      platform: $(platform).text()
      server: $(server).text()
      app: $(app).text()
      branch: $(branch).text()
      suite: $(suite).text()
      tests: tests
      device: $(device).text()
    }
    window.location.href = "/testrunner?reply=true&platform=#{json['platform']}&server=#{json['server']}&app=#{json['app']}&branch=#{json['branch']}&suite=#{json['suite']}&tests=#{json['tests']}&device=#{json['device']}"
