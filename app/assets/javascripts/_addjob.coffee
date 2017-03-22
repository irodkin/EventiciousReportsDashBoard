
$(document).on "click", "#addJobButton", ()->
	title = $('#jobName').val()
	$.ajax
		url: 'api/testrun/createJob'
		type: 'POST'
		dataType: 'json'
		data: 
			title: title
		error: ()->
			alert "error!"
		success: (response)->
			$('#addJobContainer').modal('hide')
			$('.dropdown-menu').append('<li><a class="select-job">' + response['title'] + '</a></li>')
