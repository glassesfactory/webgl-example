###
//////////////////////////
#
# リソースロード時に適当に表示するよ
#
//////////////////////////
###
class Loading
	constructor:()->
		$container = $('<div id="preloader" />')
		$container.css({top:WindowManager.halfH - 25, left:WindowManager.halfW - 100})
		$container.append('<img class="animate" src="/assets/images/loading.png" width="200" height="50">')
		$('body').append($container)

	#止める
	stop:()->
		$container = $('#preloader')
		$container.empty()
		$container.append('<img class="fadeout" src="/assets/images/loading.png" width="200" height="50">')
		$('.fadeout').on 'webkitAnimationEnd', @fadeOutCompleteHandler

	#フェードアウト完了処理
	fadeOutCompleteHandler:(event)->
		$('#preloader').remove()
		#ロゴが消えたことを通知
		$(window.App).trigger('hided')
		