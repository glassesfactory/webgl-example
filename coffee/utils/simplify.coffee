do(window)->
	delegater = (target, func)->
		return ()->
			func.apply(target, arguments)

	constrain = (v,min,max)->
		if v<min
			v=min
		else if v>max
			v=max
		return v
	window.delegater = delegater
	window.constrain = constrain