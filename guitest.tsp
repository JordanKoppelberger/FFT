function debug(string)
	if debug_key == true then
		print(string)
	end
end

function isPowerOfTwo (x)
  
 	powersOfTwo = {1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,
 				65536,131072,262144,524288,1048576,2097152,4194304,8388608,
    			16777216,33554432,67108864,134217728,268435456,536870912,
    			1073741824,2147483648}

 	exponent = 1
 	while (powersOfTwo[exponent] < x and exponent < 31) do
   		exponent = exponent + 1
   	end
 	return (x == powersOfTwo[exponent]), powersOfTwo[exponent]
end



function fft_stage(x,xi)

debug("~~~~~~~new~~~~~~~")
	local N = table.getn(x)
	local X = {}
	local Xi = {}
	debug(N)
	
	if N > 2 then -- go deeper
		debug("\tinside if",N)
		local x0 = {}
		local x0i = {}
		local x1= {}
		local x1i = {}
		
		--sort out the evens
		local j=1
	    for k=1,N,2 do
	     	x0[j] = x[k]
	    	x0i[j] = xi[k]
	    	j=j+1
	 	end
	 	
	 	
	 	--sort out the odds
	 	local j = 1 
 		for k=2,N,2 do
			x1[j] = x[k]
	    	x1i[j] = xi[k]
	    	j=j+1
		end
		
		--recursive call
		local X0,X0i = fft_stage(x0,x0i)
		local X1,X1i = fft_stage(x1,x1i)
		debug("~outside~")
		
		
		--do math
		
		for i=1,N/2 do 
			a = math.cos(-2 * math.pi*(i-1)/N)
        	b = math.sin(-2 * math.pi*(i-1)/N)
        	
        	
        	local first = a*X1[i]
       		local outside = a*X1i[i]
        	local inside = b*X1[i]
        	local last = (-1)*b*X1i[i]
	        
	    	X[i]      = X0[i] + ( first + last )
        	X[i+N/2]  = X0[i] - ( first + last )
        
        	Xi[i]     = X0i[i] + ( inside + outside )
        	Xi[i+N/2] = X0i[i] - ( inside + outside )
		end
		return X,Xi
		
		
	--once down to 2 elements swap then send recursive
	elseif N == 2 then--back up
		debug("back")
		X[1] = x[1] + x[2]
	    X[2] = x[1] - x[2]
	    --Input signal should always be real so these will always be 0
    	Xi[1] = 0 --xi[1] + xi[2]
    	Xi[2] = 0 --xi[1] - xi[2]
		return X,Xi
	elseif N == 1 then -- with new zero padding should never hit this case
		debug("Pad")
		x[2] = 0
		xi[2] = 0 
		
	end
	
end

function fft_main(x,xi)
	local N = table.getn(x)
	test, nearest = isPowerOfTwo(N)
	if(test == false) then
		for j = N+1,nearest do
			x[j] = 0
			xi[j] = 0
		end
	end

	X,Xi = fft_stage(x,xi)
	return X, Xi
end

function buffer_press_event(v)
	selected_buffer = v
end

function sample_press_event(v)
	Srate = v
end

function count_press_event(v)
	N = v 
end

function reading_press_event(v)
	take_readings = v
	if v == 0 then
		display.setstate(sample_id, display.STATE_INVISIBLE)
		display.setstate(count_id, display.STATE_INVISIBLE)
		display.setstate(function_id, display.STATE_INVISIBLE)
	else
		display.setstate(sample_id, display.STATE_ENABLE)
		display.setstate(count_id, display.STATE_ENABLE)
		display.setstate(function_id, display.STATE_ENABLE)
	end
end

function buffer_press_event(v)
	if v == 1 then
		meas_func = dmm.FUNC_DIGITIZE_VOLTAGE
	else
		meas_func = dmm.FUNC_DIGITIZE_CURRENT
	end
end

function fft_press_event()
	
	fr = {}
	fi = {}	
	F = {}
	Fi = {}
	
	mag = buffer.make(N, buffer.STYLE_WRITABLE_FULL)
	buffer.write.format(mag, buffer.UNIT_PERCENT, buffer.DIGITS_7_5, buffer.UNIT_HERTZ, buffer.DIGITS_7_5)
	
	--start fft
	if take_readings == 1 then
			loadstring(selected_buffer..' = buffer.make('..N..')')()
			dmm.digitize.func = meas_func
	   		dmm.digitize.count = N
	   		dmm.digitize.samplerate = Srate
	   		loadstring('dmm.digitize.read('..selected_buffer..')')()
	else
		N = loadstring('return '..selected_buffer..'.n')()
		--get sample rate from buffer		
	end
	
	--Copy Chosen buffer into real and imaginary structures
	for j=1,N do
		loadstring('fr['..j..'] = '..selected_buffer..'['..j..']')()
		fi[j] = 0
	end
	
	--Do FFT
	F,Fi = fft_main(fr,fi)
	
	--update N for zero padding so resolution is correct
	N = table.getn(F)
	Sres = Srate/N
	maxF = Sres * N/2
		
	--Copy into writable buffer
	for j=1,table.getn(F)/2 do
		Fmag = 20*math.log10(math.sqrt(math.pow(F[j],2) + math.pow(Fi[j],2))) 		-- calculate magnitude
		freq = (j-1)*Sres															-- calculate frequency 
		buffer.write.reading(mag, Fmag, freq )	
	end
	
	--Graph
	--display.graph.removeall(display.SCREEN_GRAPH)
	--display.graph.add(display.SCREEN_GRAPH, sig)
	--display.graph.select(display.SCREEN_GRAPH,  sig)
	--display.graph.scalex(display.SCREEN_GRAPH,display.XSCALE_SMART)	
	--display.graph.add(display.SCREEN_GRAPH, mag)
	--display.graph.select(display.SCREEN_GRAPH,  mag)	
	--display.graph.scalex(display.SCREEN_GRAPH,display.XSCALE_OFF, display.AXIS_NORMAL, 0, maxF)
	--display.graph.scaley(display.SCREEN_GRAPH,display.YSCALE_SMART, display.AXIS_NORMAL)
	--display.changescreen(display.SCREEN_GRAPH)
end

-- set defaults
Srate = 1/1E-6
selected_buffer = "FFT"
N = 1024
take_readings = 1
meas_func = dmm.FUNC_DIGITIZE_VOLTAGE

--create elements
display.clear(display.SCREEN_HOME)
fft_swipe_id = display.create(display.SCREEN_HOME, display.OBJ_SWIPE, "FFT")
buffer_id = display.create(fft_swipe_id, display.OBJ_EDIT_STRING, 175, 5, "Buffer", "", display.SFORMAT_BUFFER_NAME)
display.setvalue(buffer_id, selected_buffer)
sample_id = display.create(fft_swipe_id, display.OBJ_EDIT_NUMBER, 175, 70, "Sample Rate", "100-1000", display.NFORMAT_EXPONENT, Srate)
count_id = display.create(fft_swipe_id, display.OBJ_EDIT_NUMBER, 175, 135, "Count", "100-1000", display.NFORMAT_INTEGER, N)
reading_id = display.create(fft_swipe_id, display.OBJ_EDIT_CHECK, 520, 0, "Take Readings", "Line 2", 1)
function_id = display.create(fft_swipe_id, display.OBJ_EDIT_OPTION, 435, 70, "Function", "", "DIGI V", "DIGI I")
fft_id = display.create(fft_swipe_id, display.OBJ_BUTTON, 600, 10, "Do FFT")

--set events
display.setevent(buffer_id, display.EVENT_PRESS, "buffer_press_event(%value)")
display.setevent(sample_id, display.EVENT_PRESS, "sample_press_event(%value)")
display.setevent(count_id, display.EVENT_PRESS, "count_press_event(%value)")
display.setevent(reading_id, display.EVENT_PRESS, "reading_press_event(%value)")
display.setevent(function_id, display.EVENT_PRESS, "function_press_event(%value)")
display.setevent(fft_id, display.EVENT_PRESS, "fft_press_event()")