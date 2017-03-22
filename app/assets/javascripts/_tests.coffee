
$(document).on "click", "#tests .label-info", ()->
	if $(this).hasClass('test-active')
		$(this).removeClass('test-active')
		$(this).removeClass('test-failed')
		$(this).removeClass('test-pending')
		if ($('.test-active').length < 1)
			$('.headTag').addClass('test-active')
	else if !$(this).hasClass('headTag')
		$('.headTag').removeClass('test-active')
		$(this).addClass('test-active')
	else if $(this).hasClass('headTag')
		tags = $('#tests .label-info')
		tags.removeClass('test-active')
		tags.removeClass('test-failed')
		tags.removeClass('test-pending')
		$(this).addClass('test-active')

$(document).on "mouseenter", ".tooltips", ()->
	$(this).children('section').show();

$(document).on "mouseleave", ".tooltips", ()->
	$(this).children('section').hide();
