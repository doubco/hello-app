express = require "express"
path = require "path"
favicon = require "serve-favicon"
logger = require "morgan"
cookieParser = require "cookie-parser"
bodyParser = require "body-parser"
i18n = require "i18n"

passport = require "passport"
LocalStrategy = require('passport-local').Strategy

locales = ['tr', 'en']
defaultLocale = 'tr'
nonlocale = ["behance","social"]

i18n.configure
  locales: locales
  defaultLocale: defaultLocale
  updateFiles: true
  objectNotation: true
  directory: __dirname + '/locales'
  indent: '\t'
  
index = require('./routes/index')
users = require('./routes/users')

social = require('./routes/social')
forms = require('./routes/forms')


app = express()

# sockets = require("./sockets/io")

app.use(favicon(path.join(__dirname,'public','images','favicon.ico')))
app.use(logger('dev'))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded())

app.use(passport.initialize())
app.use(passport.session())

app.use(i18n.init)
app.use (req, res, next) ->
  res.locals.__ = res.__ = () ->
    i18n.__.apply(req, arguments)
  next()

app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')

app.use(cookieParser())
app.use(express.static(path.join(__dirname, 'public')))

passport.use(new LocalStrategy(

  (username, password, done) ->
    User.findOne { username: username }, (err, user) ->

      if err
        done(err)

      if !user
        done(null, false, { message: 'Incorrect username.' })

      if !user.validPassword(password)
        done(null, false, { message: 'Incorrect password.' })
      
      done(null, user)

))

passport.serializeUser (user, done) ->
  done(null, user.id)

passport.deserializeUser (id, done) ->
  User.findById id, (err, user) ->
    done(err, user)


app.use (req, res, next) ->
  locale = req.url.split('/')[1]
  if locale in locales
    req.setLocale(locale)
    res.cookie('locale', locale)
    if req.url is '/'+locale
      res.redirect('/'+locale+'/')
  else if req.url is '/'
    req.setLocale(defaultLocale)
    res.cookie('locale', defaultLocale)
    res.redirect('/'+defaultLocale+'/')
  else
    if !locale in nonlocale
      console.log locale
      err = new Error('Not Found')
      err.status = 404
      next(err)

  next()


app.use('/', index)
app.use('/:locale/users', users)

app.use('/social', social)
app.use('/forms', forms)



app.use (req, res, next) ->
  err = new Error('Not Found')
  err.status = 404
  next(err)

if app.get('env') is 'development'
  app.use (err, req, res, next) ->
    res.status(err.status || 500)
    res.render 'error',
        message: err.message,
        error: err

app.use (err, req, res, next) ->
  res.status(err.status || 500)
  res.render 'error',
      message: err.message,
      error: {}


module.exports = app
