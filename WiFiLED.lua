node.compile("WiFiLED_ws2812.lua")
dofile("WiFiLED_ws2812.lc")
node.compile("WiFiLED_mqtt.lua")
dofile("WiFiLED_mqtt.lc")
---[[
node.compile("WiFiLED_webServer.lua")
dofile("WiFiLED_webServer.lc");--]]
--dofile("WiFiLED_webServer.lua");
node.compile("WiFiLED_endUserSetup.lua")
dofile("WiFiLED_endUserSetup.lc")

function init()
    print("*** Initialising ***")

    initWs2812()

    local wifiMode = wifi.getdefaultmode()
    local wifiStatus = wifi.sta.status()
    
    startWifiEventMonitoring()

    if wifiMode == wifi.SOFTAP or wifiMode == wifi.STATIONAP then
        print("In either SOFTAP or STATIONAP mode, so starting config portal")
        startEndUserSetup()
    end
    
    if(wifiStatus == wifi.STA_GOTIP) then 
        print(" ... already connected, so starting server")
        startServer() 
        connectToMQTT()
    end
end

function startWifiEventMonitoring()
    print("... starting wifi event monitoring")
    wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function() 
            print("Connected wifi")
        end)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function() 
            print("Disconnected wifi")
        end)
    wifi.eventmon.register(wifi.eventmon.STA_AUTHMODE_CHANGE, function() 
            print("Wifi AuthMode changed")
        end)
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function() 
            print("IP address: " .. wifi.sta.getip())
            startServer()
            connectToMQTT()
        end)
    wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function() 
            print(" - DHCP timeout ... please check your network DHCP settings and restart")
        end)
    wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function() 
            print(" - New access point client connected ... no action currently defined")
        end)
    wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, function() 
            print(" - Access point client disconnected ... no action currently defined")
        end)
    --wifi.eventmon.register(wifi.eventmon.AP_PROBEREQRECVED, ...)
end

init()