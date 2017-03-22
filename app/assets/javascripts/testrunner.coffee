# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.run_after_login = false

readCookie = (name)->
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

setCookie = (cookieName, cookieValue)->
	day = 1000 * 60 * 60  * 24
	today = new Date()
	expire = today + day
	document.cookie = cookieName + "=" + escape(cookieValue) + ";expires=" + (20 * expire).toString()

login = (username, password) ->
	setCookie("username", username)
	setCookie("password", password)
	$('#signIn').text("Logged In")

getTest = (suite)->
	$.ajax
		url: 'testrunner/tests'
		type: 'GET'
		dataType: 'html'
		data:
			suite: suite
		success: (response)->
			$('#tests').html(response)

getParams = ()->
	query = window.location.search.substring(1)
	raw_vars = query.split("&")
	params = {}
	for v in raw_vars
		[key, val] = v.split("=")
		params[key] = decodeURIComponent(val)
	params

$(document).on "click", ".select-job", ()->
	$('#current_job').text($(this).text())
	getBuilds()

$(document).on "click", "#addJob", ()->
	$('#addJobContainer').modal('show')

$(document).on "click", "#signIn", ()->
	$('#login').modal('show')

$(document).on "click", ".list-group-item-info", ()->
	$(this).siblings('.active').removeClass('active')
	$(this).addClass('active')

$(document).on "click", "#platform span.label", ()->
	$('.activeDevice').removeClass("activeDevice")
	$(this).addClass("activeDevice")

$(document).on "change", "#username", ()->
	$(this).removeClass('empty')
	if $('#password').val() == ''
		$('#loginButton').addClass('disabled')
	else
		$('#loginButton').removeClass('disabled')

$(document).on "change", "#password", ()->
	$(this).removeClass('empty')
	if $('#username').val() == ''
		$('#loginButton').addClass('disabled')
	else
		$('#loginButton').removeClass('disabled')

$(document).on "click", "#suite .list-group-item-info", ()->
	getTest($(this)[0].id)

$(document).on "click", "#server .list-group-item-info", ()->
	server = $(this)[0].id
	locale = $('#locale .active')[0].id
	switch server
		when "Production"
			switch locale
				when "ru" then $('#appId').val('4193 or 4330')
				when "en" then $('#appId').val('4331 or 4332')
		when "Test"
			switch locale
				when "ru" then $('#appId').val('4389 or 4452')
				when "en" then $('#appId').val('4454 or 4455')

$(document).on "click", "#locale .list-group-item-info", ()->
	locale = $(this)[0].id
	server = $('#server .active')[0].id
	switch locale
		when "ru"
			switch server
				when "Production" then $('#appId').val('4193 or 4330')
				when "Test" then $('#appId').val('4389 or 4452')
		when "en"
			switch server
				when "Production" then $('#appId').val('4331 or 4332')
				when "Test" then $('#appId').val('4454 or 4455')

$(document).on "click", "#loginButton", ()->
	if $('#loginButton').hasClass('disabled')
		$('#username').addClass('empty')
		$('#password').addClass('empty')
	else
		login($('#username').val(), $('#password').val())
		$('#login').modal('hide')
		if window.run_after_login
			window.run_after_login = false
			$('#run').trigger("click")

$(document).on "click", "#run", ()->
	username = readCookie("username")
	password = readCookie("password")
	appId_toggle = $('#appId-toggle').data('toggles')
	rebuildApp_toggle = $('#rebuildApp-toggle').data('toggles')
	if !username || !password
		window.run_after_login = true
		$('#login').modal('show')
	else
		$('.bg_layer').fadeIn(1200)
		$('.ajaxBusy').fadeIn(700)
		job = $('#current_job').text()
		server = $('#server .active')[0].id
		#apiVersion = $('#apiVersion .active')[0].id
		platform = $('.activeDevice')[0].id
		appType = $('#appType .active')[0].id
		locale = $('#locale .active')[0].id
		branch = $('#branch').val()
		if $(appId_toggle).attr('active')
			appId = 0
		else
			appId = $('#appId').val()
		if $(rebuildApp_toggle).attr('active')
			rebuildApp = true
		else
			rebuildApp = false
		suite = $('#suite .active')[0].id
		tests = $('.test-active')
		testsArray = []
		#$.each tests, (e)-> testsArray.push("@" + $(tests[e])[0].id) #which one is faster?
		tests.each(
			(index,element)->
				testsArray.push("@" + element.id)
		)
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
			#apiVersion: apiVersion
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
			error: (jqXHR,textStatus,errorThrown)->
				$('.ajaxBusy').fadeOut(200)
				$('.bg_layer').fadeOut(500)
				message = jqXHR.responseText.match(/^[^\n]*\n[^\n]*\n[^\n]*/)[0]
				console.log message
				$('.alert-danger p').text(message.match(/[^\n]*$/)[0])
				setTimeout (()-> $('.alert-danger').fadeIn(700)), 700
				setTimeout (()-> $('.alert-danger').fadeOut(700)), 5000
			success: (response)->
				$('.ajaxBusy').fadeOut(200)
				$('.bg_layer').fadeOut(500)
				$('.buildNumber').text(response['build'])
				setTimeout (()-> $('.alert-success').fadeIn(700)), 700
				setTimeout (()-> $('.alert-success').fadeOut(700)), 5000
				setTimeout (()-> getBuilds()), 2000

$(document).on "click", "#addSuite", ()->
	$('#SuitesEdit').modal("show")

$(document).on "click", "#get_tests", ()->
	find = $('#find_tests').val()
	$.ajax
		url: 'api/scenarioparser/get_tests'
		type: 'GET'
		dataType: 'json'
		data: suite: find

$(document).on "page:change", ()->
	if window.location.href.includes("/testrunner")

		if readCookie("username") && readCookie("password")
			$('#signIn').text("Logged In")

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

		$('#appId-toggle').click ()->
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

		params = getParams()
		if params['rerun'] == 'true' || params['retry'] == 'true'
			$.ajax
				url: 'testrunner/retry_run_params'
				type: 'GET'
				dataType: 'json'
				data:
					report_id: params['report_id']
				error: ()->
					console.log "something going wrong"
				success: (response)->
					$('#current_job').text(response['job'])
					$("#server .#{response['server']}").trigger('click')
					if params['rerun'] == 'true'
						$('#appId-toggle').toggles(false)
						$('#appId').fadeIn(500)
						$('#rebuildApp-toggle').toggles(false)
					$("##{response['platform']}").trigger('click')
					$('#branch').val(response['branch'])
					$("#appType ##{response['app_type']}").trigger('click')
					$("#locale ##{response['locale']}").trigger('click')
					#$("#apiVersion ##{response['api_version']}").trigger('click')
					$('#appId').val(response['appid'])
					#$("#suite ##{response['suite']}").trigger('click')
					$("#suite ##{response['suite']}").addClass('active') #addClass('active') instead of trigger('click') to not call getTest() twice
					getTest(response['suite']).done((data, textStatus, jqXHR)->
						if params['retry'] == 'true'
							$.ajax
								url: 'testrunner/retry_all'
								type: 'GET'
								dataType: 'json'
								data: report_id: params['report_id']
								success: (response)->
									tags = response['tests'].split(",")
									if (tags == "")
										$(".headTag").addClass('test-active')
									else
										$('.test-active').removeClass('test-active')
										for tag in tags
											$("##{tag}").addClass('test-active')
						else if params['rerun'] == 'true'
							$.ajax
								url: 'testrunner/retry_failed'
								type: 'GET'
								dataType: 'json'
								data: report_id: params['report_id']
								success: (response)->
									failed_tests = response['failed_tests']
									pending_tests = response['pending_tests']
									#console.log failed_tests
									#console.log pending_tests
									if failed_tests != ""
										failed_tests = failed_tests.split("&&")
										failed_tests.forEach(
											(value,index,array)->
												array[index] = array[index].replace(/\w*,/g, "") #to delete common tags #temporary measure
										)
									if pending_tests != ""
										pending_tests = pending_tests.split("&&")
										pending_tests.forEach(
											(value,index,array)->
												array[index] = array[index].replace(/\w*,/g, "") #to delete common tags #temporary measure
										)
									#console.log failed_tests
									#console.log pending_tests
									if failed_tests == "" && pending_tests == ""
										$(".headTag").addClass('test-active')
									else
										$('.test-active').removeClass('test-active')
										if failed_tests != ""
											for failed_test in failed_tests
												$("##{failed_test}").addClass('test-active test-failed')
										if pending_tests != ""
											for pending_test in pending_tests
												$("##{pending_test}").addClass('test-active test-pending')
					)
		else
			$('#suite li:first').trigger('click')

		getBuilds()

		##_featurelist.html
		#$($('.feature')[0]).trigger("click")
		##
