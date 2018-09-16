LED = 0 
gpio.mode(LED,gpio.OUTPUT)
gpio.write(LED,gpio.LOW)  
tmr.delay(500000)
gpio.write(LED,gpio.HIGH)
wifi.setmode(wifi.STATION)
wifi.sta.config("XP","ping1132030944")
wifi.sta.connect()
tmr.alarm(1,3000,1,function()
    print("go to the loop")
    if wifi.sta.getip() == nil then
        print("WAITINIG GET FOR ip")
    else
        tmr.stop(1)
        gpio.write(LED,gpio.LOW)
        tmr.delay(500000)
        print("IP IS ".. wifi.sta.getip())
    end
end)  

dofile("httpServer.lua")
dofile("car.lua")
httpServer:listen(80)
Car:listen()
httpServer:use('/car',function(req,res)    
    local params = req.query
    local cmd = params['cmd']
    print(cmd)
    if(cmd == "start")then
        Car:start()
    elseif(cmd == "stop")then
        Car:stop()
    elseif(cmd == "back")then
        Car:back()
    elseif(cmd == "left")then
        Car:left()
    elseif(cmd == "right")then
        Car:right()            
    elseif(cmd =="status")then
        Car:getStatus()    
    end        
    res:type('application/json')
    res:send(string.format("{'code':'1','msg':%s}",cmd))
end)   
httpServer:use('/',function(req,res)
    res:sendFile('index.html')
end)     
   

