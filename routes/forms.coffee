express = require "express"
router = express.Router()

secret = require "../secret"
mcapi = require('mailchimp-api')
mc = new mcapi.Mailchimp(secret.mailchimp.key)

router.get "/lists", (req,res) ->
	mc.lists.list {}, (data) ->
		res.json(data.data)

router.post "/subscribe", (req, res) ->
	merge_vars = 
		mc_language: req.getLocale()
		FNAME:req.body.fname
		LNAME:req.body.lname

	email = 
		email: req.body.email

	mc.lists.subscribe 
		id: secret.mailchimp.list_id
		email:email
		merge_vars:merge_vars
		
	,(data)->
		res.json
			status: 200
			email: req.body.email
	,(error) ->
		res.json
			status: 404
			email: req.body.email
			
module.exports = router
