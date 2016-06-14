	fr = {}
	fi = {}
	t = {}
	
	
	
	test = 3
	N = 30
	debug_key = false
	
	print("start creating signal")
	
	sig = buffer.make(N, buffer.STYLE_WRITABLE_FULL)
	buffer.write.format(sig, buffer.UNIT_VOLT, buffer.DIGITS_7_5, buffer.UNIT_SECOND, buffer.DIGITS_7_5)
	
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
	
	Srate = 1/1E-6
	
	
	print("start fft")
	timestart = os.clock()
	F,Fi = fft_main(fr,fi)	
	timeend = os.clock()
	print("finished fft")
	print("Elapsed Time: " .. (timeend - timestart))
	--for key,value in pairs(F) do print(key,value) end
	--for key,value in pairs(Fi) do print(key,value) end	
	
	print("start filling buffer")
	Fmag = {}
	for j=1,table.getn(F) do 
		Fmag[j] = (2/N)*(math.sqrt(math.pow(F[j],2) + math.pow(Fi[j],2)))
		--Fmag[j] = (math.sqrt(math.pow(F[j],2) + math.pow(Fi[j],2)))
		--print(Fmag[j])
	end
	

	mag = buffer.make(table.getn(F), buffer.STYLE_WRITABLE_FULL)
	
	--~~~~~~~~~.......PR XAXIS DOES NOT PRINT HERTZ.....~~~~~~~~~~~
	--~~~~~~~~~AXIS DOES NOT PICK NEW ACTIVE BUFFER UNIT~~~~~~~~~~~~~
	--~~~~~~~~~~NO LOG ON XAXIS~~~~~~~~~~~~~~~~~
	buffer.write.format(mag, buffer.UNIT_PERCENT, buffer.DIGITS_7_5, buffer.UNIT_HERTZ, buffer.DIGITS_7_5)
	
	
	print()
	print()
	freq = {}
	
	for j=1,table.getn(F)/2 do 
		freq[j] = (j-1)*Srate/N
		buffer.write.reading(mag, Fmag[j], freq[j] )
		--print(freq[j],mag[j])
	end
	
	print("finished filling buffer")
	
	--display.graph.add(display.SCREEN_GRAPH, sig,display.ELEMENT_DATA,mag,display.ELEMENT_DATA)
