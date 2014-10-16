angular.module 'hello'
.directive 'warp', (handy) ->
	restrict: 'A'
	scope: 
		warp: '@'
		duration: '=duration'
		fix: '=fix'
	link: (scope, element, attrs) ->
		if handy.isMobile()
			multiplier = 1.5
		else
			multiplier = 1

		if scope.fix and !handy.isMobile()
			fix = parseInt(scope.fix,10)
		else
			fix = 0

		element.on "tap" , () ->
			$(".sections").animate
				scrollTop: $(".sections").scrollTop() + $("." + scope.warp).position().top + fix
			,(scope.duration*multiplier),'easeOutExpo'


.directive 'openInMap', (handy) ->
	restrict: 'C'
	scope:
		lat:"="
		lon:"="
	link: (scope, element, attrs) ->
		element.on "tap" , () ->
			handy.openInMap(scope.lat,scope.lon)
		.on "click", (e) ->
			e.preventDefault()


.directive 'warpToTop', (handy) ->
	restrict: 'C'
	link: (scope, element, attrs) ->
		if handy.isMobile()
			multiplier = 400
		else
			multiplier = 200
		element.on "tap", () ->
			$(".sections").animate
				scrollTop: 0
			,(($(".sections").scrollTop()/2)+multiplier),'easeOutExpo'


.directive 'subscribe', (handy,$http) ->
	restrict: 'C'
	link: (scope, element, attrs) ->
		input = element.find("input")
		button = element.find(".button") 

		onSuccess = (data) ->
			element.find(".wait").removeClass("message-visible")
			element.find(".success").addClass("message-visible")

			setTimeout () ->
				element.find(".success").removeClass("message-visible")
			,3000

		onError = (data) ->
			element.find(".wait").removeClass("message-visible")
			element.find(".error").addClass("message-visible")

			setTimeout () ->
				element.find(".error").removeClass("message-visible")
			,3000

		subscribe = (value) -> 
			element.find(".wait")
			.addClass("message-visible")
			$(@).blur()
			input.val("")

			$http
				method: 'POST'
				url: '/forms/subscribe'
				data:
					email: value

			.success (data,status) ->

				if data.status is 200
					onSuccess(data.email)

				if data.status is 404
					onError(data.email)

			.error (data,status) ->
					onError()

		input.on "keydown" , (event) ->
			if handy.keyboard(event,"return",false)
				subscribe(input.val())

		button.on "tap", ()->
			subscribe(input.val())

