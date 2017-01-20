--*** WiFi LED ***
-- NB: ws2812 info here: https://nodemcu.readthedocs.io/en/dev/en/modules/ws2812/
print("Initialising ws2812")
ws2812.init()
print("Writing some colours to the LEDs")
local buffer = ws2812.newBuffer(30,3)
-- Set example LEDs
buffer:fill(0,0,255)    -- Blue
buffer:set(3, 255,0,0)  -- Green
buffer:set(6, 0,255,0)  -- Red
ws2812.write(buffer)

-- Add some RGB blocks by copying buffers
local rgbBuffer = ws2812.newBuffer(3,3); rgbBuffer:set(1,0,255,0); rgbBuffer:set(2,255,0,0); rgbBuffer:set(3,0,0,255)
buffer:replace(rgbBuffer, 9)
buffer:replace(rgbBuffer, 12)
ws2812.write(buffer)

function shiftBuffer(bufferToShift, offset, displayBuffer, noLoop)
    bufferToShift = bufferToShift or buffer
    offset = offset or 1
    displayBuffer = displayBuffer or false
    noLoop = noLoop or false
    local mode = ws2812.SHIFT_LINEAR
    if not noLoop then mode = ws2812.SHIFT_CIRCULAR end
    bufferToShift:shift(offset, mode)
    if displayBuffer then
        ws2812.write(bufferToShift)
    end
end

-- Shift the whole buffer by 3
--buffer:shift(3, ws2812.SHIFT_CIRCULAR)
--ws2812.write(buffer)
--shiftBuffer(null,3,true,true) -- NB: Shifts 3, leaving a blank gap

-- NB: For info on tmr (timer), see https://nodemcu.readthedocs.io/en/dev/en/modules/tmr/
--Set animation routine
local animationTimer = tmr.create()
local animationDelay = 250
--animationTimer:register(1000, tmr.ALARM_AUTO, function() print("Tick..") end)
--animationTimer:register(250, tmr.ALARM_AUTO, function() 
-- NB: Seeing if ALARM_SEMI avoids zombie timers
animationTimer:register(animationDelay, tmr.ALARM_SEMI, function()
    --buffer:shift(1, ws2812.SHIFT_CIRCULAR)
    --ws2812.write(buffer)
    shiftBuffer(null,1,true)
    animationTimer:start()
end)
animationTimer:start()

function setRGB(r,g,b) buffer:fill(g,r,b); ws2812.write(buffer) end
function setBlue() setRGB(0,0,255) end
function setRed() setRGB(255,0,0) end
function setGreen() setRGB(0,255,0) end
function setPurple() setRGB(255,0,255) end
function setYellow() setRGB(255,255,0) end
function setWhite() setRGB(255,255,255) end
function setOff() setRGB(0,0,0) end

function setRGBCluster()
    buffer:replace(rgbBuffer, 1)
    ws2812.write(buffer)
end

function setRGBRepeat()
    buffer:replace(rgbBuffer, 1)
    buffer:replace(rgbBuffer, 4)
    buffer:replace(rgbBuffer, 7)
    buffer:replace(rgbBuffer, 10)
    buffer:replace(rgbBuffer, 13)
    buffer:replace(rgbBuffer, 16)
    buffer:replace(rgbBuffer, 19)
    buffer:replace(rgbBuffer, 22)
    buffer:replace(rgbBuffer, 25)
    buffer:replace(rgbBuffer, 28)
    ws2812.write(buffer)
end

function startAnimationIfNotRunning()
    local running, mode = animationTimer:state()
    if not running then animationTimer:start() end
end
function faster() 
    if animationDelay > 50 then animationDelay = animationDelay - 50 end
    startAnimationIfNotRunning()
    animationTimer:interval(animationDelay)
end
function slower() 
    animationDelay = animationDelay + 50
    animationTimer:interval(animationDelay)
end
function stopAnimation() 
    animationTimer:stop()
end
function setDefaultSpeed() 
    animationDelay = 250
    startAnimationIfNotRunning()
    animationTimer:interval(animationDelay)
end

local srv=net.createServer(net.TCP)
local port = 80
local homepage = "<h1>WiFi LED Homepage</h1><div>"
                    .."<a href=\"/rgb1\">RGB Cluster</a>"
                    .." <a href=\"/rgb\">RGB Repeat</a>"
                    .." <a href=\"/blue\">Blue</a>"
                    .." <a href=\"/green\">Green</a>"
                    .." <a href=\"/red\">Red</a>"
                    .." <a href=\"/purple\">Purple</a>"
                    .." <a href=\"/yellow\">Yellow</a>"
                    .." <a href=\"/white\">White</a>"
                    .." <a href=\"/off\">Off</a>"
                    .." <a href=\"/faster\">Faster</a>"
                    .." <a href=\"/slower\">Slower</a>"
                    .." <a href=\"/stopanimation\">Stop Animation</a>"
                    .." <a href=\"/defaultspeed\">Default Speed</a>"
                    .."</div>"
function startServer()
    print("Starting webserver on IP " .. wifi.sta.getip())
    -- Example with basic webserver: http://hanneslehmann.github.io/2015/01/ESP8266Module_LUA/
    srv:listen(port, function(conn)
        print("Listing on port " .. port)
        conn:on("receive",function(conn,request)
            --print(request)
            --conn:send("<h1>Hello, from WiFiLED</h1>")

            local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
            if (method == nil) then
                _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
            end
            local _GET = {}
            if (vars ~= nil)then
                for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                    _GET[k] = v
                end
            end
            local html = "<h1>Hello from WiFi LED</h1>"
            -- NB: We could now get (or example) _GET.pin == "ON1" to detect the query string values ?pin=ON1
            print("Path: " .. (path or "[nil]") .. ", request method " .. (method or "[nil]") .. ", vars = " .. (vars or "[nil]"))
            if path == "/" then
                print("Returning home page")
                html = homepage
            elseif path == "/rgb" then
                print("Setting RGB")
                setRGBRepeat()
                html = homepage
            elseif path == "/rgb1" then
                print("Setting RGB cluster")
                setRGBCluster()
                html = homepage
            elseif path == "/blue" then
                print("Setting Blue")
                setBlue()
                html = homepage
            elseif path == "/green" then
                print("Setting Green")
                setGreen()
                html = homepage
            elseif path == "/red" then
                print("Setting Red")
                setRed()
                html = homepage
            elseif path == "/purple" then
                print("Setting Purple")
                setPurple()
                html = homepage
            elseif path == "/yellow" then
                print("Setting Yellow")
                setYellow()
                html = homepage
            elseif path == "/white" then
                print("Setting White")
                setWhite()
                html = homepage
            elseif path == "/off" then
                print("Setting Off")
                setOff()
                html = homepage
            elseif path == "/faster" then
                print("Faster")
                faster()
                html = homepage
            elseif path == "/slower" then
                print("Slower")
                slower()
                html = homepage
            elseif path == "/stopanimation" then
                print("Stopping animation")
                stopAnimation()
                html = homepage
            elseif path == "/defaultspeed" then
                print("Setting default speed")
                setDefaultSpeed()
                html = homepage
            else
                print("Unknown path: " .. path)
                html = homepage
            end
            
            conn:send(html)
        end)
        conn:on("sent", function(conn)
            conn:close()
            collectgarbage()
        end)
    end)
end

function startEndUserSetup()
    print("starting end user setup ...")
    -- Start enduser network setup (see https://github.com/nodemcu/nodemcu-firmware/blob/master/docs/en/modules/enduser-setup.md)
    enduser_setup.start(
      function()
        print("Connected to wifi as:" .. wifi.sta.getip())
        enduser_setup.stop()
        startServer()
      end,
      function(err, str)
        print("enduser_setup: Err #" .. err .. ": " .. str)
      end
    );
end

function init()
    print("*** Initialising ***")
    --[[
    local ssid, password = wifi.sta.getdefaultconfig()
    print("\n Current Station configuration:\n    SSID:    " 
    .. ssid 
    .. "\n    Password: ", password)
    if ssid then
        wifi.
        startServer()
    ]]

    local wifiMode = wifi.getdefaultmode()
    local wifiStatus = wifi.sta.status()
    --[[
    print("- Default wifi mode = " .. wifiMode .. ", status = " .. wifiStatus)
    if wifiMode == wifi.STATIONAP or wifiMode == wifi.STATION then
        --print("STATIONAP mode is currently unsupported, setting AP mode and restarting")
        --wifi.setMode(wifi.SOFTAP)
        --node.restart()
        print(" ... should check status, and start server as well as config page?")
    elseif wifiMode == wifi.SOFTAP then
        startEndUserSetup()
    elseif wifiMode == wifi.STATION then
        local wifiStatus = wifi.sta.status()
        if wifiStatus == wifi.STA_IDLE then
            print("!!! Idle")
        elseif wifiStatus == wifi.STA_CONNECTING then
            print(" ... still connecting ... should set a timer to retry")
        elseif wifiStatus == wifi.STA_WRONGPWD then
            print("!!! Wrong password ... should clear settings and restart in AP mode")
        elseif wifiStatus == wifi.APNOTFOUND then
            print("!!! Not found ... please check wifi, and otherwise clear settings and resume in AP mode")
        elseif wifiStatus == wifi.STAFAIL then
            print("!!! Wifi Station FAIL ... unexpected, please check your router and settings")
        elseif wifiStatus == wifi.GOTIP then
            print(" ... Connected: IP=" .. wifi.ap.getip())
            startServer()
        else
            print(" ... Unknown status: " .. wifiStatus)
        end
    else
        print("!!! Unknown wifiMode: " .. wifiMode)
    end
    ]]
    
    startWifiEventMonitoring()

    if wifiMode == wifi.SOFTAP or wifiMode == wifi.STATIONAP then
        print("In either SOFTAP or STATIONAP mode, so starting config portal")
        startEndUserSetup()
    end
    
    if(wifiStatus == wifi.STA_GOTIP) then 
        print(" ... already connected, so starting server")
        startServer() 
    end
end

function startWifiEventMonitoring()
    print("... starting wifi event monitoring")
    wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function() 
            print(" - Connected to wifi, getting IP ... ")
        end)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function() 
            print(" - Disconnected from wifi ... no action will currently be taken")
        end)
    wifi.eventmon.register(wifi.eventmon.STA_AUTHMODE_CHANGE, function() 
            print(" - Wifi AuthMode changed ... no action currently defined")
        end)
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function() 
            print(" - Got IP address: " .. wifi.sta.getip())
            startServer()
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
    --[[
    wifi.eventmon.register(wifi.eventmon.AP_PROBEREQRECVED, function() 
            print(" - Access point probe request received ... no action currently defined")
        end)
    --]]
end

init()
