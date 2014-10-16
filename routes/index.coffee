express = require('express')
router = express.Router()
i18n = require("i18n")
moment = require('moment-timezone')

secret = require "../secret"

router.get '/:locale', (req, res) ->

	res.render 'index',
		locale:req.params.locale
		secret:secret

module.exports = router
