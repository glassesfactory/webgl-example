class Contents
	id:null
	data:{}
	$inner:null
	$base:null
	#テンプレート
	templates:_.template '<div class="contentbase"><div class="contentInner"><h1><%= title %></h1><section class="secBase"><div class="imgContainer"><img src="<%= img %>" width="300" height="300"></div><div class="right"><h2>材料</h2><ul class="ing"><% _.each(ingredients,function(meshi){ %><li><%= meshi %></li><% }) %></ul><h2>作り方</h2><ul class="dir"><% _.each(directions,function(meshi){ %><li><%= meshi %></li><% }) %></ul></div></section></div><a class="close" href="#">close</a></div>'


	#こんすとらくたー
	constructor:(id, data)->
		@id = id
		@data = data
		
	#コンテンツの表示処理
	show:()->
		#コンテンツを追加
		$('#contents').empty().html(@templates(@data))

		#薄い背景の処理
		@$base = $('.contentbase')
		@$base.css({
			width : WindowManager.WW
			height : WindowManager.WH
			opacity : 0
			})
		@$base.animate({ opacity : 1 }, 600 )

		#実際にコンテンツを表示するコンテナへの処理
		@$inner = $('.contentInner')
		@$inner.css({
			top : WindowManager.halfH - 220 + "px"
			left : WindowManager.halfW - 320 + "px"
			opacity : 0
			})

		#初めてのリクエストの時、ロゴ表示のタイミングとあわせディレイをかける
		if window.App.isFirstRequest is false	
			setTimeout ()=>
				@fadeInInner()
			, 800
		else
			@fadeInInner()

		$('.close').on 'click', @closeHandler
		return

	#inner のフェードイン処理
	fadeInInner:()->
		@$inner.addClass('bokeh').on 'webkitAnimationEnd', delegater( @, @innerFaedInCompleteHandler )

	#inner のフェードイン完了
	innerFaedInCompleteHandler:(event)->	
		@$inner.removeClass('bokeh')
		@$inner.css {opacity:1}
		@$inner.off 'webkitAnimationEnd', @innerFaedInCompleteHandler

	#閉じるボタンがクリックされた時
	closeHandler:(event)->
		event.preventDefault()
		$('#contents').empty()
		window.App.change('/')