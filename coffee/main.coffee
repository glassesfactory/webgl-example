# world = null
win = window
$App = null
class Router extends Kazitori
	resourceLoaded:false
	isFirstRequest:false
	pool:{}
	state:null
	routes:
		"":"index"
		"/":"index"
		":id":"show"
	index:()->
		@state = "index"

	show:(id)->
		@state = id
		if @resourceLoaded
			if id in @pool
				contents = @pool[id]
			else
				contents = new Contents(id, @recipes[id-1])
				@pool[id] = contents
			contents.show()

loading = null
$(document).ready ()->
	App = win.App = new Router({root:'/'})
	$App = $(App)
	$win = $(window)
	WindowManager.start()
	loadResource()
	$win.on 'firstrequested', firstRequestCompleteHandler
	return


loadResource =()->
	loading = new Loading()
	$App.on 'loaded', loadCompleteHandler
	
	$.ajax({
		url:"/assets/js/recipe.json"
		dataType:"json"
		success:(event)->
			App.recipes = event.recipes
			World.init()
			
			WindowManager.handlers.push((event)->
				$("#contentFooter").css({bottom:0})
			)
			update()
		})	


update = ()->
	requestAnimationFrame(update)
	World.update()


loadCompleteHandler =(event)->
	$App.on 'hided', hidedHandler		
	loading.stop()
	window.App.resourceLoaded = true


hidedHandler =(event)->
	if App.state is "index"
		World.intro()
	else
		World.AddRecipes()
		App.show(App.state)

firstRequestCompleteHandler=(event)->
	App.isFirstRequest = true


#ロゴを追加
appendLogo =()->
	$('body').append('<div class="logo bokeh"><img src="/assets/images/logo.png" width="300" height="55"></div>')
	$('.logo').on 'webkitAnimationEnd' ,　logoFadeInCompleteHandler

logoFadeInCompleteHandler =(event)->
	$('.logo').removeClass('bokeh')
	if App.isFirstRequest is false
		$(window).trigger('firstrequested')
	$('.logo').off 'webkitAnimationEnd', logoFadeInCompleteHandler
