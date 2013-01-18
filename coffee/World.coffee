do(window)->
	World =()->
		throw new Error("a")
	w = World
	w.win= null

	w.camera=null
	w.scene=null
	w.controller=null
	w.renderer=null
	w.light=null
	w.meshs=[]
	w.group = new THREE.Object3D()
	w.recipes = []


	#interactions
	w.projector = null
	w.mouse = new THREE.Vector2()
	w.currentOver = null
	w.controller = null
	w.currentClick = null

	
	#（；`・ω・）ｏ━ヽ_｡_･_ﾟ_･_フ))　初期化するよ！
	World.init=()->
		w.win = window
		w.camera = new THREE.PerspectiveCamera(75, WindowManager.WW / WindowManager.WH, 1, 5000)
		w.camera.position.z = 1000

		w.scene = new THREE.Scene()
		w.scene.add( @camera )

		w.scene.add(new THREE.AmbientLight(0x666666))

		light = new THREE.DirectionalLight(0xffffff, 1.1)
		light.position.set( 0, 500, 1500 )
		light.castShadow = true

		light.shadowCameraNear = 200
		light.shadowCameraFar = @camera.far
		light.shadowCameraFov = 75

		light.shadowBias = -0.00022
		light.shadowDarkness = 0.5

		light.shadowMapWidth = 2048
		light.shadowMapHeight = 2048

		w.scene.add(light)
		w.light = light

		w.projector = new THREE.Projector()


		w.renderer = new THREE.WebGLRenderer({antialias:true})
		w.renderer.setClearColorHex(0xffffff,1)
		w.renderer.setSize( WindowManager.WW, WindowManager.WH )
		w.renderer.domElement.style.position = 'absolute'

		$('#container').append( w.renderer.domElement )

		WindowManager.bind(w.renderer, w.camera)

		w.initObject()

	#オブジェクトの初期化
	World.initObject=()->
		i = 1
		maps = []
		while i < 17
			maps.push(THREE.ImageUtils.loadTexture("/assets/images/intro_" + i + ".png"))
			i++

		i = 0
		while i < 4
			j = 0
			while j < 4
				geo = new THREE.CubeGeometry(200,200,200)
				material = new THREE.MeshLambertMaterial({map:maps[i*4+j]})
				mesh = new THREE.Mesh(geo, material)
				mesh.position.x = j * 200 - 300
				mesh.position.y = 600 - i * 200 - 300
				mesh.rotation.x = Math.random() * 180 / Math.PI
				mesh.rotation.y = Math.random() * 180 / Math.PI
				mesh.rotation.z = Math.random() * 180 / Math.PI
				mesh.rotation.z *= if Math.random() > 0.5 then -1 else 1
				w.meshs.push mesh
				w.group.add(mesh)
				j++
			i++

		i = 0
		recipes = w.win.App.recipes
		recipeTextures = []
		len = recipes.length
		while i < 2
			j = 0
			while j < 5  
				map = THREE.ImageUtils.loadTexture(recipes[i*5+j].img)
				geo = new THREE.CubeGeometry(200,200,200)
				material = new THREE.MeshLambertMaterial({map:map})
				mesh = new THREE.Mesh(geo, material)
				mesh.position.x = 400 * j - 800
				mesh.position.y = 200 - 400 * i
				mesh.direction = if Math.random() > 0.5 then -1 else 1
				mesh.contentID = recipes[i*5+j].id
				mesh.scale.set(0,0,0)
				mesh.isBig = false
				mesh.big = ()->
					self = @
					new TWEEN.Tween(@.scale)
					.to({x:1.3,y:1.3,z:1.3}, 300)
					.easing(TWEEN.Easing.Quartic.In)
					.onComplete(()->
						self.isBig = true
						)
					.start()
					new TWEEN.Tween(@.rotation)
					.to({x:0,y:0,z:0},300)
					.easing(TWEEN.Easing.Quartic.InOut)
					.delay(180)
					.start()

				mesh.small =()->
					self = @
					new TWEEN.Tween(@.scale)
					.to({x:1,y:1,z:1}, 300)
					.easing(TWEEN.Easing.Quartic.Out)
					.onComplete(()->
						self.direction *= -1
						self.isBig = false
						)
					.start()					

				
				w.recipes.push mesh
				j++
			i++

		#マテリアルの準備が整ったことを通知
		$(w.win.App).trigger('loaded')

	#イントロ
	World.intro=()->
		w.scene.add( w.group )
		TWEEN.removeAll()
		for obj in w.meshs
			new TWEEN.Tween(obj.rotation).to({x:0, y:0}, Math.random() * 800 + 800)
			.easing(TWEEN.Easing.Exponential.InOut).start()
			new TWEEN.Tween(obj.rotation).to({z:0},Math.random()* 600 + 600)
			.easing(TWEEN.Easing.Exponential.InOut)
			.delay(500).start()

		new TWEEN.Tween(w.win).to({}, 2000).onUpdate(World.render).onComplete(World.nextScene).start()


	#次の動き
	World.nextScene=()->
		for obj in w.meshs
			new TWEEN.Tween(obj.position)
			.to({y:Math.random() * -1500 - 1000}, Math.random() * 600 + 600)
			.easing(TWEEN.Easing.Quartic.InOut)
			.delay(Math.random() * 400 + 400)
			.start()

		new TWEEN.Tween(w.win).to({}, 1600)
		.onUpdate(World.render)
		.onComplete(()->
			w.scene.remove(w.group)
			World.AddRecipes()
		).start()

	#レシピを表示
	World.AddRecipes=()->
		appendLogo()
		i = 0
		len = w.recipes.length
		while i < len
			obj = w.recipes[i]
			w.scene.add(obj)
			new TWEEN.Tween(obj.scale)
			.to({x:1,y:1,z:1}, 400)
			.easing(TWEEN.Easing.Quartic.Out)
			.delay(i*80)
			.start()
			i++

		new TWEEN.Tween(w.win).to({}, 2000).onUpdate(World.render).start()

		w.win.addEventListener 'mousemove', w.mousemoveHandler, false
		#グルグル回せる
		w.controller = new THREE.TrackballControls( w.camera, w.renderer.domElement )
		w.controller.rotateSpeed = 0.4
		w.controller.addEventListener('change', w.render )

		w.renderer.domElement.addEventListener 'click', w.clickHandler, false


	#あっぷでーと
	World.update=()->
		w.render()
		TWEEN.update()
		if w.controller?
			w.controller.update()
		return


	#れんだりんぐ
	World.render=()->
		#適当に回すよ
		for obj in w.recipes
			if not obj.isBig
				obj.rotation.x += (Math.random() / 180 * Math.PI * 0.2) * obj.direction
				obj.rotation.y += (Math.random() / 180 * Math.PI * 0.2) * obj.direction

		if w.win.App.state is "index"
			#ロールオーバーチェック
			w.renderMouseMove()

		w.renderer.render(w.scene, w.camera)


	#マウスオーバー周りの処理
	World.renderMouseMove=()->
		intersects = w.computeIntesects()
		if intersects.length > 0
			if w.currentOver != intersects[0].object and intersects[0].object.hasOwnProperty("contentID")
				if w.currentOver
					w.currentOver.small()
				w.currentOver = intersects[0].object
				w.currentOver.big()
		else
			if w.currentOver
				w.currentOver.small()
			w.currentOver = null



	#マウスとオブジェクトが重なっているかどうかをチェックする
	World.computeIntesects=()->
		vect = new THREE.Vector3( w.mouse.x, w.mouse.y, 0.5 )
		w.projector.unprojectVector(vect, w.camera)
		
		ray = new THREE.Raycaster( w.camera.position, vect.sub( w.camera.position ).normalize())
		
		intersects = ray.intersectObjects( w.scene.children )
		return intersects


	#マウスが動いた時の処理
	World.mousemoveHandler =(event)->
		w.mouse.x = ( event.clientX / WindowManager.WW ) * 2 - 1
		w.mouse.y = - ( event.clientY / WindowManager.WH ) * 2 + 1


	#キューブがクリックされた時の処理
	World.clickHandler =(event)->
		intersects = w.computeIntesects()
		if intersects.length > 0
			if w.currentClick != intersects[0].object and intersects[0].object.hasOwnProperty("contentID")
				w.currentClick = intersects[0].object
				id = w.currentClick.contentID
				w.win.App.change(id)
		else
			w.currentClick = null
			return


	World = w
	window.World = World