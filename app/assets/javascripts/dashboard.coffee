# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

get_report_table_body = ()->
	filters = {}
	filters["count"] = $("#reports_number_to_display").val()
	filter_names = ["platform", "server", "appid", "app_type", "locale", "branch", "suite", "tests", "user"]
	for f in filter_names
		value = $("##{f}_filter_input").val()
		filters[f] = value if value != ''
	#console.log filters
	$.ajax
		url: 'dashboard/get_report_table_body'
		type: 'GET'
		data: filters: filters
		success: (response)->
			$('table.table tbody').html(response)
			#add some events to newly rendered html chunk
			$('.result').tooltip({title: "<div><div><strong>click me to see a report</strong></div><span class=\"label label-success\">green</span> is awesome :)</div><div><span class=\"label label-warning\">yellow</span> is good :|</div><div><span class=\"label label-danger\">red</span> it is bad :(</div>", html: true})
			$('.rerun').tooltip({title: "<strong>rerun only failed tests in run with <i>no</i> build again</strong>", html: true})
			$('.retry').tooltip({title: "<strong>retry all tests in run with build again</strong>", html: true})

$(document).on "click", ".deleteButton", ()->
	current_record_tr = $(this).parents('tr')[0]
	$.ajax
		url: 'dashboard/' + $(current_record_tr).attr('recordid')
		type: 'DELETE'
		$(current_record_tr).fadeOut(700)
		setTimeout(get_report_table_body, 700)

$(document).on "click", "#refresh", ()->
	get_report_table_body()

$(document).on "click", "#reset_filters", ()->
	$("tr th input").each(
		(inp)->
			if this.value != ''
				this.value = ''
				localStorage.setItem(this.id, '')
	)
	get_report_table_body()

$(document).on "change", "#reports_number_to_display", ()->
	value = this.value
	localStorage.setItem(this.id, value)
	get_report_table_body()

$(document).on "change", "tr th input", ()-> #filter by column
	value = this.value
	localStorage.setItem(this.id, value)
	get_report_table_body()
	#column_number=$(this).parent().index()+1
	#rows=$("table.table tr").slice(1, -1)
	#rows_contains=rows.has("td:nth-child(#{column_number}):contains(#{value})")
	#$(this).parent().attr('title', "Total number of reports with this parameter: #{rows_contains.size()}")

$(document).on "page:change", ()->
	if !window.location.href.includes("/testrunner")
		r_n_t_d = localStorage.getItem("reports_number_to_display")
		if r_n_t_d == null
			$("#reports_number_to_display").val(8) 
			localStorage.setItem("reports_number_to_display", 8)
		else
			$("#reports_number_to_display").val(r_n_t_d)

		$("tr th input").each(
			(inp)-> this.value = localStorage.getItem(this.id)
		)
		
		get_report_table_body()
