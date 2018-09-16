dofile("config.lua")
wificount = 1
nodeName = "test01"
print("ssid:"..ssid.."  password:"..password)
if ssid == "" then
    local config = {}
    config.ssid = 'xxxx'
    wifi.sta.config(config)
end
if ssid ~= "" and password ~= "" then
    wifi.setmode(wifi.STATION)
    local config = {}
    config.ssid = ssid
    config.pwd = password
    config.save = true
    wifi.sta.config(config)
    wifi.sta.connect()
    tmr.delay(2000000)
end

if wifi.sta.getip() == nil then
    tmr.alarm(1,3000,1,function()
        print("go to the loop")
        if wifi.sta.getip() == nil then
            wificount = wificount + 1
            print("WAITINIG GET FOR ip")
        else
            print("get ip success "..wifi.sta.getip())
            tmr.stop(1)
            dofile("mqtt.lua")
            return
        end    
        if wificount >= 5 then
            wifi.setmode(wifi.SOFTAP)
            cfg = {}
            cfg.ssid="NODE_CLOUD"..nodeName
            cfg.pwd="12345678"
            local apres = wifi.ap.config(cfg)
            if apres then
                print("ap success")
            else
                print("ap fail")
            end
            ipcfg = {}
            ipcfg.ip="192.168.8.1"
            ipcfg.netmask="255.255.255.0"
            ipcfg.gateway="192.168.8.1"
            wifi.ap.setip(ipcfg)
            wifi.ap.dhcp.start()
            tmr.stop(1)
        end
    end)  

end


dofile("httpServer.lua")
dofile("setwifi.lua")
dofile("switch.lua")
httpServer:listen(80)

httpServer:use('/setting',function(req,res)
    local params = req.query
    local ssid = params['ssid']
    local pwd = params['pwd']
    local clientId = params['clientId']
    print(ssid,pwd,clientId)
    WifiSet:init(ssid,pwd,clientId)
    res:type('application/json')
    res:send(string.format("{'code':'1','msg':%s}","success"))
    collectgarbage()
end)

httpServer:use('/switch/on',function(req,res)
    local params = req.query
    local pin = params['pin']
    res:type('application/json')
    print(pin)
    if pin ~= "3" and pin ~= "4" then
        res:send(string.format("{'code':'2','msg':%s}","pin is not special"))
   else
        Switch:on(tonumber(pin))
        res:send(string.format("{'code':'1','msg':%s}","success"))
   end
   collectgarbage()
end)   


httpServer:use('/switch/off',function(req,res)
    local params = req.query
    local pin = params['pin']
    res:type('application/json')
    if pin ~= "3" and pin ~= "4" then
        res:send(string.format("{'code':'2','msg':%s}","pin is not special"))
   else
        Switch:off(tonumber(pin))
        res:send(string.format("{'code':'1','msg':%s}","success"))
   end
   collectgarbage()
end)



httpServer:use('/switch/status',function(req,res)
    local params = req.query
    local pin = params['pin']
    res:type('application/json')
    if pin ~= "3" and pin ~= "4" then
        res:send(string.format("{'code':'2','msg':%s}","pin is not special"))
   else
        result = Switch:status(tonumber(pin))
        res:send(string.format("{'code':'1','msg':%s,'res':%d}","success",result))
   end
   collectgarbage()
end)

httpServer:use('/wifi/mac/get',function(req,res)
    res:type('application/json')
    res:send(string.format("{'code':'1','msg':'success','res':%s}",wifi.sta.getmac()))
    collectgarbage()
end)
    
httpServer:use('/',function(req,res)
    res:sendFile('setting.html')
end)   

httpServer:use('/reset',function(req,res)
    if file.open("config.lua","w") then
        file.writeline("ssid=''")
        file.writeline("password=''")
        file.writeline("clientId=''")
        file.close()
        node.restart()
    end
    res:type('application/json')
    res:send(string.format("{'code':'1','msg':%s}","success"))
    collectgarbage()
end)

httpServer:use('/pos',function(req,res)
    res:type('application/json')
    res:send(string.format("{'code':'1','pos':%s}",clientId))
    collectgarbage()
end)

