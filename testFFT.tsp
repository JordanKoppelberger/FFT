	-- structures
	fr = {}
	fi = {}
	t = {}		
	
	--settings
	test = 1 				-- 1= sinewave 2= Dc value 3 = shelf
	N = 1024			-- number of samples
	debug_key = false 		-- output debug statements
	Srate = 1/1E-6			-- sampling rate
	
	--create buffers
	sig = buffer.make(N, buffer.STYLE_WRITABLE_FULL)
	buffer.write.format(sig, buffer.UNIT_VOLT, buffer.DIGITS_7_5, buffer.UNIT_SECOND, buffer.DIGITS_7_5)
	
	mag = buffer.make(N, buffer.STYLE_WRITABLE_FULL)
	buffer.write.format(mag, buffer.UNIT_PERCENT, buffer.DIGITS_7_5, buffer.UNIT_HERTZ, buffer.DIGITS_7_5)
	
	--for testing purposes
	print("start creating signal")	
	for j=1,N do
		if test == 1 then
	    	t[j]=(j-1)*1E-6
	    	fr[j] = math.sin(2*math.pi*10000*t[j])
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
	freq = {}
	Fmag = {}	
	for j=1,table.getn(F)/2 do
		Fmag[j] = (2/N)*(math.sqrt(math.pow(F[j],2) + math.pow(Fi[j],2))) 	-- calculate magnitude
		freq[j] = (j-1)*Srate/N												-- calculate frequency 
		buffer.write.reading(mag, Fmag[j], freq[j] )						-- store in buffer
		print(F[j],Fi[j])
	end
	
	print("finished filling buffer")
	
	display.graph.add(display.SCREEN_GRAPH, sig,display.ELEMENT_DATA,mag,display.ELEMENT_DATA)
