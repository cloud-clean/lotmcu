position = clientId
mqtt_server = "202.182.118.148"
mqtt_port = 61613
mqtt_user = "lot2"
mqtt_password = "cloudhai"
topic = "lot"
client_id = "lot_"..tostring(node.chipid())

function mqtt_init()
    local ip = wifi.sta.getip()
    if ip == nil then
        return
    end
    print("init mqtt")
    m = mqtt.Client(client_id,120,mqtt_user,mqtt_password)
    m:lwt("/lwt","offline",0,0)
    m:connect(mqtt_server,mqtt_port,function(client)
        print("connect to "..mqtt_server)
    end,
    function(cleint,reason)
        print("fail reason:".. reason)
    end)

    
    m:on("connect",function(client) 
        print("connected")
        m:subscribe(topic,2,function(conn)
            print("subscribe "..topic.." success")
        end)
        stopReconnect()
    end)
    
    m:on("offline",function(client) 
        print("offline")
        reconnect()
    end)

    m:on("message",function(client,topic,data)
        print(topic..":"..data.." local pos:"..position)
        if data ~= nil then
            msg = cjson.decode(data)
            pos = ""
            status = 0
            for k,v in pairs(msg) do
                if k == "pos" then
                    pos = v
                end
                if k == "status" then
                    status = tonumber(v)
                end 
            end
            if position == pos then
                local param = {}
                param["pos"] = position
                param["status"] = status
                local p = cjson.encode(param)
                gpio.mode(3,gpio.OUTPUT)
                gpio.write(3,status)
                http.post("http://lot.btprice.com/api/lot/update",
                "Content-Type: application/json\r\n",
                p,
                function(code,data)
                end)
            end
        end
        collectgarbage()    
    end)
end
    

function reconnect()
    tmr.alarm(2,5000,1,function()
        print("reconnent mqtt")
        m:close()
        m:connect(mqtt_server,mqtt_port)
    end)
end

function stopReconnect()
    collectgarbage()
    tmr.stop(2)
end


mqtt_init()


