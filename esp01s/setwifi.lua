WifiSet={}

function setting(ssid,pwd)
    print("ssid:"..ssid.."  pwd:"..pwd)
    wifi.setmode(wifi.STATION)
    local config = {}
    config.ssid=ssid
    config.pwd=pwd
    config.save=false
    wifi.sta.config(config)
    wifi.sta.connect()
    tmr.delay(2000000)
end  

function WifiSet:init(ssid,pwd,clientId)
    --save to file
    print("init wifi")
    count = 0
    setting(ssid,pwd)
    tmr.alarm(1,3000,tmr.ALARM_AUTO,function()
        count = count + 1
        local ip = wifi.sta.getip()
        if ip ~= nil then
            print("connect wifi success")
            if file.open("config.lua","w") then
                file.writeline("ssid='"..ssid.."'")
                file.writeline("password='"..pwd.."'")
                file.writeline("clientId='"..clientId.."'")
                file.close()
                node.restart()
            end
            tmr.stop(1)
        end    
    end)
end

  
