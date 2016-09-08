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
      setTimeout (()->
        $(current_record_tr).remove()
        $("#reports_number_to_display").trigger("change")), 700
      

  $("#refresh").click ->
    window.location.reload()

  $("#reset_filters").click ->
    $("tr th input").each(
      (inp)->
        if $(this).val()!=''
          $(this).val("")
          $(this).trigger("change")
    )

  $(".reply").click ->
    parent_td = $(this).parents('tr')[0]
    json = {
      report_id: $(parent_td).attr("recordid")
    }
    window.location.href = "/testrunner?reply=true&report_id=#{json['report_id']}"


  $(".rerun").click ->
    parent_td = $(this).parents('tr')[0]
    json = {
      report_id: $(parent_td).attr("recordid")
    }
    window.location.href = "/testrunner?rerun=true&report_id=#{json['report_id']}"


  $('.result').tooltip({title: "<div><div><strong>click me to see a report</strong></div><span class=\"label label-success\">green</span> is awesome :)</div><div><span class=\"label label-warning\">yellow</span> is good :|</div><div><span class=\"label label-danger\">red</span> it is bad :(</div>", html: true})
  $('.rerun').tooltip({title: "<strong>rerun only failed tests in run with <i>no</i> build again</strong>", html: true})
  $('.reply').tooltip({title: "<strong>reply all tests in run with build again</strong>", html: true})

  $("#reports_number_to_display").change ->
    value=Number($(this).val())
    localStorage.setItem("reports_number_to_display", value)
    rows=$('table.table tr').slice(1, -1)
    rows.hide()
    rows.filter(":not([class*='rejectedBy'])").slice(0, value).show()

  $("tr th input").change -> #filter by column
    value=$(this).val()
    localStorage.setItem($(this).parent().text().trim(), value)
    column_number=$(this).parent().index()+1
    rows=$("table.table tr").slice(1, -1)
    rows_contains=rows.has("td:nth-child(#{column_number}):contains(#{value})")
    $(this).parent().attr('title', "Total number of reports with this parameter: #{rows_contains.size()}")

    rows_contains.removeClass("rejectedBy#{column_number}")
    rows.has("td:nth-child(#{column_number}):not(:contains(#{value}))").addClass("rejectedBy#{column_number}")
    $("#reports_number_to_display").trigger("change")

  #filters on page load
  $("tr th input").each(
    (inp)->$(this).val(localStorage.getItem($(this).parent().text().trim()))
  )
  $("#reports_number_to_display").val(localStorage.getItem("reports_number_to_display"))
  all_empty=true
  $("tr th input").each(
    (inp)->
      if $(this).val()!=''
        all_empty=false
        $(this).trigger("change")
  )
  if all_empty
    $("#reports_number_to_display").trigger("change")
