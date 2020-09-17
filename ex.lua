mytimer = tmr.create()
print(mytimer:state()) -- nil
mytimer:register(5000, tmr.ALARM_SINGLE, function() 
    print("hey there") 
    running, mode = mytimer:state()
    print("running: " .. tostring(running) .. ", mode: " .. mode) -- running: false, mode: 0
    end)
mytimer:start();

