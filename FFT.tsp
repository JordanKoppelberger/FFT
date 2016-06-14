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
			a = math.cos(-2*math.pi*(i-1)/N)
        	b = math.sin(-2*math.pi*(i-1)/N)
        	
        	
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
    	Xi[1] = xi[1] + xi[2]
    	Xi[2] = xi[1] - xi[2]
		return X,Xi
	elseif N == 1 then
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