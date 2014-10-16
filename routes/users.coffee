express = require('express')
router = express.Router()
i18n = require("i18n")
passport = require('passport')

router.post '/login', passport.authenticate('local') , (req, res) ->
    res.redirect('/' + req.user.username)

module.exports = router