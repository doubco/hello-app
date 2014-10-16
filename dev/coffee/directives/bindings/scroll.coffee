angular.module 'hello'
.directive 'sections', ($timeout,handy) ->
	restrict: 'C'
	link: (scope, element, attrs) ->
		$timeout () ->

			element.bind "scroll" ,(event,delta) ->

				if !handy.isMobile()
				
					if $(".sections").scrollTop() > $(window).height()
						$(".warp-to-top").addClass "warp-to-top-in-da-house"
					else
						$(".warp-to-top").removeClass "warp-to-top-in-da-house"

					$(".reveal").each () ->
						if handy.inViewport(element,$(@))
							if not $(@).hasClass "revealed"
								$(@).addClass "revealed"
						else
							$(@).removeClass "revealed"
				else
					
					$(".reveal").css
						opacity:1

		,1

		return