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
    json = {
      report_id: $(parent_td).attr("recordid")
    }
    window.location.href = "/testrunner?reply=true&report_id=#{json['report_id']}"

$ ->
  $(".rerun").click ->
    parent_td = $(this).parents('tr')[0]
    json = {
      report_id: $(parent_td).attr("recordid")
    }
    window.location.href = "/testrunner?rerun=true&report_id=#{json['report_id']}"
