	--test
	
	-- structures
	fr = {}
	fi = {}
	t = {}		
	
	--settings
	test = 1 				-- 1= sinewave 2= Dc value 3 = shelf
	N = 2048			-- number of samples
	debug_key = false 		-- output debug statements
	Srate = 1/1E-6			-- sampling rate
	
	--create buffers
	sig = buffer.make(N, buffer.STYLE_WRITABLE_FULL)
	buffer.write.format(sig, buffer.UNIT_VOLT, buffer.DIGITS_7_5, buffer.UNIT_SECOND, buffer.DIGITS_7_5)
	
	--for testing purposes
	print("start creating signal")	
	for j=1,N do
		if test == 1 then
	    	t[j]=(j-1)*1E-6
	    	fr[j] = 20*math.sin(2*math.pi*10000*t[j]) + 100*math.sin(2*math.pi*100000*t[j])
	    end
	    if test == 2 then
	    	fr[j] = 1
	    end
	    if test == 3 then 
	    	if j < N/2 then
	    		fr[j] = 1	    
	    	else
	    		fr[j] = 0	
	   		end
	   	end
	    fi[j] = 0
	    buffer.write.reading(sig, fr[j], j)
	end
	print("finished creating signal")		
	
	
	print("start fft")
	timestart = os.clock()
	F,Fi = fft_main(fr,fi)	
	timeend = os.clock()
	print("finished fft")
	print("Elapsed Time: " .. (timeend - timestart))
	--for key,value in pairs(F) do print(key,value) end
	--for key,value in pairs(Fi) do print(key,value) end	
	
	print("start filling buffer")	
	--~~~~~~~~~.......PR XAXIS DOES NOT PRINT HERTZ.....~~~~~~~~~~~
	--~~~~~~~~~AXIS DOES NOT PICK NEW ACTIVE BUFFER UNIT~~~~~~~~~~~~~
	--~~~~~~~~~~NO LOG ON XAXIS~~~~~~~~~~~~~~~~~	
	
	print()
	print()
	N = table.getn(F)
	mag = buffer.make(N/2, buffer.STYLE_WRITABLE_FULL)
	buffer.write.format(mag, buffer.UNIT_DECIBEL, buffer.DIGITS_7_5, buffer.UNIT_HERTZ, buffer.DIGITS_7_5)
	Sres = Srate/N
	maxF = Sres * N/2	
	for j=1,N/2 do
		Fmag = 20*math.log10(math.sqrt(math.pow(F[j],2) + math.pow(Fi[j],2))) 	-- calculate magnitude
		freq = (j-1)*Sres														-- calculate frequency 
		buffer.write.reading(mag, Fmag, freq )									-- store in buffer
		--print(F[j],Fi[j])
	end
	
	print("finished filling buffer")
	
	
	--display.graph.removeall(display.SCREEN_GRAPH)
	--display.graph.add(display.SCREEN_GRAPH, sig)
	--display.graph.select(display.SCREEN_GRAPH,  sig)
	--display.graph.scalex(display.SCREEN_GRAPH,display.XSCALE_SMART)	
	display.graph.add(display.SCREEN_GRAPH, mag, display.ELEMENT_DATA, mag, display.ELEMENT_EXTRA)
	display.graph.select(display.SCREEN_GRAPH,  mag)	
	display.graph.scalex(display.SCREEN_GRAPH,display.XSCALE_OFF, display.AXIS_NORMAL, 0, maxF)
	display.graph.scaley(display.SCREEN_GRAPH,display.YSCALE_SMART, display.AXIS_NORMAL)
	--display.changescreen(display.SCREEN_GRAPH)
