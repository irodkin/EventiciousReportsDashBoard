
$(document).on "click", "#addNewFeatureForm", ()->
	$(this).fadeOut(500)
	$('.addContainer').fadeIn(1400)

$(document).on "click", "#addNewFeature", ()->
	title = $('#title').val()
	tag = $('#tag').val()
	$.ajax
		url: 'api/scenarioparser/add_feature'
		type: 'POST'
		dataType: 'html'
		data:
			title: title
			tag: tag
		success: (response)->
			$('#featurelist').html(response)
			$('.addContainer').fadeOut(100)
			$('.feature').last().trigger('click')
			$('#addNewFeatureForm').fadeIn(500)
