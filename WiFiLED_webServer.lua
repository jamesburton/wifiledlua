local srv=net.createServer(net.TCP)
local port = 80
function serveHtml(conn, filename)
    print("serveHtml: " .. filename)
    -- Send content type (MIME) header
    --[[
    local code = 200
    local statusString = "OK"
    local mimeType = "text/html"
    conn:send("HTTP/1.0 " .. code .. " " .. statusString .. "\r\nServer: wifiled-httpserver\r\nContent-Type: " .. mimeType .. "\r\n")
    --]]
    -- Send file
    local bytesRemaining = file.list()[filename]
    print("File: " .. file.list()[filename])
    local chunkSize = 1024
    local fileHandle = file.open(filename)
    while bytesRemaining > 0 do
        local bytesToRead = 0
        if bytesRemaining > chunkSize then bytesToRead = chunkSize else bytesToRead = bytesRemaining end
        local chunk = fileHandle:read(bytesToRead)
        conn:send(chunk)
        print("Sent " .. #chunk .. " byte(s)")
        bytesRemaining = bytesRemaining - #chunk
        chunk = nil
        collectgarbage()
    end
    fileHandle.close()
    fileHandle = nil
    collectgarbage()
end
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
            local filename = "homepage.html"
            -- NB: We could now get (or example) _GET.pin == "ON1" to detect the query string values ?pin=ON1
            print("Path: " .. (path or "[nil]") .. ", request method " .. (method or "[nil]") .. ", vars = " .. (vars or "[nil]"))
            if path == "/" then
                print("Returning home page")
            elseif path == "/rgb" then
                print("Setting RGB")
                setRGBRepeat()
            elseif path == "/rgb1" then
                print("Setting RGB cluster")
                setRGBCluster()
            elseif path == "/blue" then
                print("Setting Blue")
                setBlue()
            elseif path == "/green" then
                print("Setting Green")
                setGreen()
            elseif path == "/red" then
                print("Setting Red")
                setRed()
            elseif path == "/purple" then
                print("Setting Purple")
                setPurple()
            elseif path == "/yellow" then
                print("Setting Yellow")
                setYellow()
            elseif path == "/white" then
                print("Setting White")
                setWhite()
            elseif path == "/off" then
                print("Setting Off")
                setOff()
            elseif path == "/faster" then
                print("Faster")
                faster()
            elseif path == "/slower" then
                print("Slower")
                slower()
            elseif path == "/stopanimation" then
                print("Stopping animation")
                stopAnimation()
            elseif path == "/defaultspeed" then
                print("Setting default speed")
                setDefaultSpeed()
            else
                print("Unknown path: " .. path)
            end
            
            --conn:send(html)
            serveHtml(conn, filename)
            collectgarbage()
        end)
        conn:on("sent", function(conn)
            conn:close()
            collectgarbage()
        end)
    end)
end
