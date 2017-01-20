dofile("LoaderLastUpdated.lua")
dofile("LoaderSettings.lua")

-- Switch DNS to Google (from OpenDNS [default])
net.dns.setdnsserver("8.8.8.8",0)
net.dns.setdnsserver("8.8.4.4",1)

local function remoteUpdateAuto(thenCB)
    if autoUpdate then remoteUpdate(thenCB) else thenCB() end
end

local newUpdateTime = nil
local function getNewUpdateTime(thenCB, remainingFiles)
    http.get(remoteUpdateHost .. remoteUpdatePath .. "utc", nil, function(code,data) 
        print("newUpdateTime=" .. data)
        newUpdateTime=tonumber(data) 
        remoteUpdate(thenCB, remainingFilse)
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
    remainingFiles.remove(1)

    remoteFile = remoteUpdateFiles[i]
    lastUpdated = remoteUpdateLastUpdated[remoteFile]
    print("Loader:update() i=" .. i .. ", remoteFile=" .. remoteFile .. ", lastUpdated=" .. lastUpdated)
    local url = remoteUpdateHost .. remoteUpdatePath .. remoteUpdateProject .. "/" .. remoteFile .. "?since=" .. lastUpdated
    print("... url=" .. url);
    http.get(url, nil, function(code,data)
        print(#remainingFiles .. " file(s) remaining")
        if node ~= 200 then
            print(" ... code=" .. code);
        else
            if data ~= "NC" then
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
            else
                print("File not changed: " .. remoteFile)
            end
        end
        remoteUpdate(thenCB, remainingFiles)
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

remoteUpdateAuto(function() autoStartIfDefined() end)
