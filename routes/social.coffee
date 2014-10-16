express = require "express"
router = express.Router()
request = require "request"
async = require "async"

secret = require "../secret"

Memcached = require "memcached"
memcached = new Memcached('localhost:11211')

networks = ["twitter","facebook","googleplus","behance","instagram","github","linkedin","vimeo"]
duration = 1800

networkCallbacks =
	vimeo: (callback)->
		memcached.get "vimeo_data" , (err, data) ->
			if err
				return callback(null, 0)
			if data is false

				headers=
        	'Authorization': secret.vimeo.auth
        	'Accept': '*/*'

				apiUrl = "https://api.vimeo.com/me/followers"

				request.get { url: apiUrl, headers:headers, json: true }, (err, res, body) ->
					if err
						return callback(null, 0)
					stats=
						followers: body["total"]

					memcached.set "vimeo_data", stats, duration, (err)->
						return callback(null, stats)

			else
				return callback(null, data)

	linkedin: (callback)->
		memcached.get "linkedin_data" , (err, data) ->
			if err
				return callback(null, 0)
			if data is false
				apiUrl = "https://api.linkedin.com/v1/companies/#{secret.linkedin.user}:(num-followers)?format=json&oauth2_access_token=#{secret.linkedin.token}"
				request.get { url: apiUrl, json: true }, (err, res, body) ->
					if err
						return callback(null, 0)
					stats=
						followers: body["numFollowers"]

					memcached.set "linkedin_data", stats, duration, (err)->
						return callback(null, stats)

			else
				return callback(null, data)

	github: (callback)->
		memcached.get "github_data" , (err, data) ->
			if err
				return callback(null, 0)
			if data is false
				headers=
        	'User-Agent': 'Doub.co Portfolio'
				apiUrl = "https://api.github.com/orgs/#{secret.github.user}"
				request.get { url: apiUrl, headers:headers, json: true }, (err, res, body) ->
					if err
						return callback(null, 0)
					stats=
						followers: body["followers"]

					memcached.set "github_data", stats, duration, (err)->
						return callback(null, stats)

			else
				return callback(null, data)

	instagram: (callback)->
		memcached.get "instagram_data" , (err, data) ->
			if err
				return callback(null, 0)
			if data is false

				apiUrl = "https://api.instagram.com/v1/users/#{secret.instagram.user}/?access_token=#{secret.instagram.access_token}"
				request.get { url: apiUrl, json: true }, (err, res, body) ->
					if err
						return callback(null, 0)
					stats=
						media: body["data"]["counts"]["media"]
						followers: body["data"]["counts"]["followed_by"]

					memcached.set "instagram_data", stats, duration, (err)->
						return callback(null, stats)

			else
				return callback(null, data)

	twitter: (callback) ->
		oauth = 
			consumer_key: secret.twitter.consumer_key
			consumer_secret: secret.twitter.consumer_secret
			access_token: secret.twitter.access_token
			access_token_secret: secret.twitter.access_token_secret

		memcached.get "twitter_data" , (err, data) ->
			if err
				return callback(null, 0)
			if data is false

				apiUrl = "https://api.twitter.com/1.1/users/show.json?screen_name=#{secret.twitter.screen_name}"

				request.get { url: apiUrl, oauth:oauth, json: true }, (err, res, body) ->
					if err
						return callback(null, 0)

					stats=
						followers: body["followers_count"]
						friends: body["friends_count"]

					memcached.set "twitter_data", stats, duration, (err)->
						return callback(null, stats)

			else
				return callback(null, data)

	facebook: (callback) ->
		memcached.get "facebook_data" , (err, data) ->
			if err
				return callback(null, 0)
			if data is false
				apiUrl = 'https://graph.facebook.com/fql?q=SELECT%20url,%20normalized_url,%20share_count,%20like_count,%20comment_count,%20total_count,commentsbox_count,%20comments_fbid,%20click_count%20FROM%20link_stat%20WHERE%20url="'+secret.facebook.url+'"'
				request.get { url: apiUrl, json: true }, (err, res, body) ->
					if err
						return callback(null, 0)
					stats = 
						like: body.data[0]["like_count"]
						share: body.data[0]["share_count"]
						click: body.data[0]["click_count"]
						comment: body.data[0]["comment_count"]

					memcached.set "facebook_data", stats, duration, (err)->
						return callback(null, stats)
			else
				return callback(null, data)

	googleplus: (callback) ->
		memcached.get "googleplus_data" , (err, data) ->
			if err
				return callback(null, 0)
			if data is false
				apiUrl = "https://www.googleapis.com/plus/v1/people/#{secret.google.user}?key=#{secret.google.key}"
				request.get apiUrl, (err, res, body) ->
					if err
						return callback(null, 0)

					stats = 
						circled: JSON.parse(body)["circledByCount"]
						plus: JSON.parse(body)["plusOneCount"]

					memcached.set "googleplus_data", stats, duration, (err)->
						return callback(null, stats)
			else
				return callback(null, data)

	behance: (callback) ->
		memcached.get "behance_data" , (err, data) ->
			if err
				return callback(null, 0)

			if data is false
				apiUrl = "http://www.behance.net/v2/teams/#{secret.behance.user}/?api_key=#{secret.behance.api_key}"
				request.get apiUrl, (err, res, body) ->

					all_stats = JSON.parse(body)["team"]["stats"]

					stats = 
						appreciations: all_stats["appreciations"]
						views: all_stats["views"]
						followers: all_stats["followers"]
						members: all_stats["members"]
						projects: all_stats["projects"]
						wips: all_stats["wips"]

					if err
						return callback(null, 0)
					memcached.set "behance_data", stats, duration, (err)->
						return callback(null, stats)
			else

				return callback(null, data)

router.get "/all", (req, res) ->
	networksToRequest = {}

	networks.forEach (network) ->
		networksToRequest[network] = (callback) ->
			networkCallbacks[network](callback)

	async.parallel networksToRequest, (err, results)->
		res.json results

router.get "/flush/:provider", (req, res) ->
	provider = req.params.provider

	if provider
		if provider in networks
			memcached.del "#{provider}_data", (err) ->
				res.json "#{provider} cache is flushed."
	else
		networks.forEach (network) ->
			memcached.del "#{network}_data", (err) ->
				console.log "#{network} cache is flushed."
		res.json "Caches flushed."

module.exports = router
