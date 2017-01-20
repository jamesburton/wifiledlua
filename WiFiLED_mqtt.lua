local mq = nil
local keepAlive = 120
function connectToMQTT()
    local clientId = "wifiled:" .. node.chipid()
    print("MQTT clientId=" .. clientId)

    local server = "m20.cloudmqtt.com"
    local port = 12773
    local securePort = 22773
    local secure = false
    local user = "oyeypfqd"
    local password = "H4T1oWKApitM"
    
    mq = mqtt.Client(clientId, keepAlive, user, password)

    -- Configure "Last Will and Testament", e.g. disconnect message
    mq:lwt("/lwt", "offline", 0, 0)

    mq:on("connect", function(client) 
        print("MQTT connected") 
        
        mq:subscribe("/" .. clientId,0, function(client) print("* subscribe success") end)
        -- publish a message with data = hello, QoS = 0, retain = 0
        --mq:publish("/" .. clientId,"hello",0,0, function(client) print("* sent") end)
        local url = "http://" .. wifi.sta.getip() .. "/";
        mq:publish("/" .. clientId,"Connected on <a href=\"" .. url .. "\">" .. url .. "</a>",0,0, function(client) print("* sent") end)
        collectgarbage()
    end)
    mq:on("offline", function(client) print("MQTT offline") end)

    mq:on("message", function(client, topic, data)
        print(topic .. ":")
        if data ~= nil then
            if data == "white" then setWhite()
            elseif data == "red" then setRed()
            elseif data == "green" then setGreen()
            elseif data == "blue" then setBlue()
            elseif data == "purple" then setPurple()
            elseif data == "yellow" then setYellow()
            elseif data == "off" then setOff()
            end
            print(data)
        end
    end)

    local portToUse = port
    if useSecurePort then portToUse = securePort end
    mq:connect(server, portToUse, useSecurePort, --[[autoreconnect]] true,
        function(client) 
            print("* MQTT connected") 
            -- subscribe topic with qos = 0
            --mq:subscribe("/topic",0, function(client) print("subscribe success") end)
            mq:subscribe("/" .. clientId,0, function(client) print("subscribe success") end)
            -- publish a message with data = hello, QoS = 0, retain = 0
            mq:publish("/" .. clientId,"hello",0,0, function(client) print("sent") end)
            
            mq:close();
            -- NB: you can call m:connect again
        end,
        function(client, reason) 
            print("* MQTT failed: " .. reason) 
        end)
end
