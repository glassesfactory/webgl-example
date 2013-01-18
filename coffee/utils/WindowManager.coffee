do(window)->
	WindowManager =()->
		throw new Error("インスタンス化できまてん")

	win = WindowManager.win = window

	WindowManager.handlers = []
	
	WindowManager.start =()->
		WindowManager.resize()
		$(window).on "resize", WindowManager.resize

	WindowManager.stop =()->
		$(window).off "resize", WindowManager.resize

	WindowManager.bind =(renderer, camera)->
		WindowManager.renderer = renderer
		WindowManager.camera = camera

	WindowManager.resize =(event)->
		win = window
		WindowManager.WW = win.innerWidth
		WindowManager.WH = win.innerHeight
		WindowManager.halfW = WindowManager.WW / 2
		WindowManager.halfH = WindowManager.WH / 2

		if WindowManager.camera?
			WindowManager.camera.aspect = WindowManager.WW / WindowManager.WH
			WindowManager.camera.updateProjectionMatrix()
		if WindowManager.renderer?
			WindowManager.renderer.setSize( WindowManager.WW, WindowManager.WH )

		for handler in WindowManager.handlers
			handler.apply( handler, event )
	
	window.WindowManager = WindowManager