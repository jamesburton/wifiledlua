--WiFiLED_ws2812

local buffer
local animationTimer
local animationDelay = 250
-- Add some RGB blocks by copying buffers
local rgbBuffer = ws2812.newBuffer(3,3); rgbBuffer:set(1,0,255,0); rgbBuffer:set(2,255,0,0); rgbBuffer:set(3,0,0,255)

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
        shiftBuffer(null,1,true)
        animationTimer:start()
    end)
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