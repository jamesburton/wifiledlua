require("LoaderLastUpdated")
require("LoaderSettings")

-- Switch DNS to Google (from OpenDNS [default])
net.dns.setdnsserver("8.8.8.8",0)
net.dns.setdnsserver("8.8.4.4",1)

--[[
-- From http://www.esp8266.com/viewtopic.php?f=19&t=1149
local function download(path, filename, cb)
  tmr.wdclr()
  httpDL = require("httpDL")
  collectgarbage()
  httpDL.download(remoteUpdateHost, 80, path..filename, filename, cb)
  httpDL = nil
  package.loaded["httpDL"]=nil
  collectgarbage()
end 
]]

local function remoteUpdateAuto(thenCB)
    if autoUpdate then remoteUpdate(thenCB) else thenCB() end
end

local newUpdateTime = nil
local function getNewUpdateTime(thenCB, remainingFiles)
    print("Getting time from " .. remoteUpdateHost .. remoteUpdatePath .. "utc")
    --[[http.get("http://" .. remoteUpdateHost .. ":80" .. remoteUpdatePath .. "utc", 
        "GET " .. remoteUpdatePath .. "utc\r\n" ..
        "Host: " .. remoteUpdateHost .. "\r\n" ..
        "Connection: close\r\n"..
        "Accept-Charset: utf-8\r\n"..
        "Accept-Encoding: \r\n"..
        "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n".. 
        "Accept: */*\r\n\r\n"]]
    http.get("http://luaupdatehost.azurewebsites.net/projectFiles/utc"
        --, nil
        , "GET /projectFiles/utc/ HTTP/1.0\r\n"..
              "Host: luaupdatehost.azurewebsites.net\r\n"..
              "Connection: close\r\n"..
              "Accept-Charset: utf-8\r\n"
        , function(code,data) 
            if code == 200 then
                print("newUpdateTime=" .. data)
                newUpdateTime=tonumber(data) 
                remoteUpdate(thenCB, remainingFilse)
            else
                print("Failed to get server timestamp: code=" .. code or "<Unknown>")
                tmr.alarm(0, 2500, tmr.ALARM_SINGLE, function() thenCB() end)
            end
        end)
end

function remoteUpdate(thenCB, remainingFiles)
    remainingFiles = remainingFiles or remoteUpdateFiles
    if #remainingFiles == 0 then 
        file.open("LoaderLastUpdated.lua")
        file.writeline("-- Set the Last Updated [global] variables")
        file.writeline("remoteUpdateLastUpdated = {}")
        for i=1,#remoteUpdateFiles do
            file.writeline("remoteUpdateLastUpdated[\"" .. remoteUpdateFiles[i] .. "\"]=" .. remoteUpdateLastUpdated[remoteUpdateFiles[i]])
        end
        file.close()
        thenCB()
    else
        if not newUpdateTime then getNewUpdateTime(thenCB, remainingFiles) end
    end

    local remoteFile = remainingFiles[1]
    print("remoteFile=" .. remoteFile)
    table.remove(remainingFiles, 1)

    remoteFile = remoteUpdateFiles[1]
    lastUpdated = remoteUpdateLastUpdated[remoteFile] or 0
    print("Loader:update():- remoteFile=" .. remoteFile .. ", lastUpdated=" .. lastUpdated)
    local url = "http://" .. remoteUpdateHost .. ":80" .. remoteUpdatePath .. remoteUpdateProject .. "/" .. remoteFile .. "?since=" .. lastUpdated
    print("... url=" .. url);
    http.get(url, nil, function(code,data)
        print(#remainingFiles .. " file(s) remaining")
        if node == 200 then
            if data == "NC" then
                print("File not changed: " .. remoteFile)
            else
                if file.open(remoteFile, "w+") then
                    print(" ... writing: " .. remoteFile)
                    file.write(data)
                    file.close()
                    
                    -- Should compile file
                    if compileFiles then 
                        print(" ... compiling: " .. compileFile)
                        node.compile(remoteFile)
                    end
                    remoteUpdateLastUpdated[remoteFile] = newUpdateTime
                else
                    print("Failed to open file: " .. remoteFile)
                end
            end
        else
            print(" ... code=" .. code);
        end
        remoteUpdate(thenCB, remainingFiles)
        collectgarbage()
    end)        
end

local function autoStartIfDefined()
    if autoStart then
        local withExtension
        if compileFiles then withExtension = autoStart .. ".lc" else withExtension = autoStart .. ".lua" end
        dofile(withExtension)
        collectgarbage()
    else
        print("- No autoStart file defined, you will need to manually run a program")
    end
end

--remoteUpdateAuto(function() autoStartIfDefined() end)
getNewUpdateTime(function() autoStartIfDefined() end)
