--WiFiLED_ws2812

local buffer
local animationTimer
local animationDelay = 250
-- Add some RGB blocks by copying buffers
local rgbBuffer = ws2812.newBuffer(3,3); rgbBuffer:set(1,0,255,0); rgbBuffer:set(2,255,0,0); rgbBuffer:set(3,0,0,255)
local cylonBuffer = ws2812.newBuffer(3,3); cylonBuffer:set(1,80,0,0); cylonBuffer:set(2,255,0,0); cylonBuffer:set(3,80,0,0)
WiFiLED.MODE_LOOP = 0
WiFiLED.MODE_BOUNCE = 1
WiFiLED.MODE_CYLON = 2
WiFiLED.MODE_PULSE = 3
WiFiLED.MODE_RANDOM = 4
WiFiLED.mode = WiFiLED.MODE_LOOP
WiFiLED.offset = 1 -- Use for bounce count/etc.
WiFiLED.animVar = 0 -- Use for direction/sin deg/etc.
WiFiLED.numberLEDs = 30

function initWs2812()
    --*** WiFi LED ***
    -- NB: ws2812 info here: https://nodemcu.readthedocs.io/en/dev/en/modules/ws2812/
    print("Initialising ws2812")
    ws2812.init()
    buffer = ws2812.newBuffer(30,3)
    print("Writing some colours to the LEDs")
    setOff()
    -- Setup timer
    animationTimer = animationTimer or tmr.create()
    -- NB: Seeing if ALARM_SEMI avoids zombie timers
    animationTimer:register(animationDelay, tmr.ALARM_SEMI, function()
        animationLoop()
    end)
    animationTimer:start()
end

function animationLoop()
    if WiFiLED.mode == WiFiLED.MODE_CYLON then
        clear(WiFiLED.offset, 3)
        if WiFiLED.animVar == 0 then
            if WiFiLED.offset == WiFiLED.numberLEDs - 3 then
                WiFiLED.animVar = 1
            else
                WiFiLED.offset = WiFiLED.offset + 1
            end
        else
            if WiFiLED.offset == 1 then
                WiFiLED.animVar = 0
            else
                WiFiLED.offset = WiFiLED.offset - 1
            end
        end
        setCylonCluster(WiFiLED.offset)
        ws2812.write(buffer)
    else--if WiFiLED.mode == WiFiLED.MODE_LOOP
        shiftBuffer(null,1,true)
    end
    animationTimer:start()
end

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
    collectgarbage()
end

function setRGB(r,g,b) buffer:fill(g,r,b); ws2812.write(buffer) end
function setBlue() setRGB(0,0,255) end
function setRed() setRGB(255,0,0) end
function setGreen() setRGB(0,255,0) end
function setPurple() setRGB(200,0,200) end
function setYellow() setRGB(200,200,0) end
function setWhite() setRGB(255,255,255) end
function setOff() setRGB(0,0,0) end

function setRGBCluster(offset)
    offset = offset or 1
    buffer:replace(rgbBuffer, offset)
    ws2812.write(buffer)
end
function setCylonCluster(offset)
    offset = offset or 1
    buffer:replace(cylonBuffer, offset)
    ws2812.write(buffer)
end
function clear(offset, length)
    offset = offset or 1
    length = length or 1
    buffer:set(offset,0,0,0)
end

function setRGBRepeat()
    for i = 1,28,3 do buffer:replace(rgbBuffer, 1) end
    ws2812.write(buffer)
end

function startAnimationIfNotRunning()
    local running, mode = animationTimer:state()
    if not running then animationTimer:start() end
    collectgarbage()
end
function faster() 
    if animationDelay > 50 then 
        animationDelay = animationDelay - 50 
    elseif animationDelay > 20 then
        animationDelay = animationDelay - 15
    elseif animationDelay > 5 then
        animationDelay = animationDelay - 5
    end
    startAnimationIfNotRunning()
    animationTimer:interval(animationDelay)
end
function slower() 
    if animationDelay <= 20 then
        animationDelay = animationDelay + 5
    elseif animationDelay <= 50 then
        animationDelay = animationDelay + 15
    else
        animationDelay = animationDelay + 50
    end
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
function brighten()
    buffer:fade(2,ws2812.FADE_IN)
    ws2812.write(buffer)
end
function darken()
    buffer:fade(2,ws2812.FADE_OUT)
    ws2812.write(buffer)
end
function setCylon()
    WiFiLED.mode = WiFiLED.MODE_CYLON
end
function setLoop()
    WiFiLED.mode = WiFiLED.MODE_LOOP
end
