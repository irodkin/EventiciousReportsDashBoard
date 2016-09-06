# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on "page:change", ->
  $(".deleteButton").click ->
    current_record_tr = $(this).parents('tr')[0]
    $.ajax
      url: 'dashboard/' + $(current_record_tr).attr('recordid')
      type: 'DELETE'
      $(current_record_tr).fadeOut(700)

$(document).on "page:change", ->
  $("#refresh").click ->
    window.location.reload()

$(document).on "page:change", ->
  $(".reply").click ->
    parent_td = $(this).parents('tr')[0]
    json = {
      report_id: $(parent_td).attr("recordid")
    }
    window.location.href = "/testrunner?reply=true&report_id=#{json['report_id']}"


$(document).on "page:change", ->
  $(".rerun").click ->
    parent_td = $(this).parents('tr')[0]
    json = {
      report_id: $(parent_td).attr("recordid")
    }
    window.location.href = "/testrunner?rerun=true&report_id=#{json['report_id']}"


$(document).on "page:change", ->
  $('.result').tooltip({title: "<div><div><strong>click me to see a report</strong></div><span class=\"label label-success\">green</span> is awesome :)</div><div><span class=\"label label-warning\">yellow</span> is good :|</div><div><span class=\"label label-danger\">red</span> it is bad :(</div>", html: true})
  $('.rerun').tooltip({title: "<strong>rerun only failed tests in run with <i>no</i> build again</strong>", html: true})
  $('.reply').tooltip({title: "<strong>reply all tests in run with build again</strong>", html: true})
