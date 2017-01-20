dofile("LoaderLastUpdated.lua")
dofile("LoaderSettings.lua")

local function remoteUpdateAuto(enabled)
    enabled = enabled or autoUpdate
    if enabled then remoteUpdate() end
end

function remoteUpdate()
    local lastUpdated
    local remoteFile
    local fetched
    for i = 1, #remoteUpdateFiles do
        remoteFile = remoteUpdateFiles[i]
        lastUpdated = remoteUpdateLastUpdated[remoteFile]
        print("Loader:update() i=" .. i .. ", remoteFile=" .. remoteFile .. ", lastUpdated=" .. lastUpdated)
        -- Should fetch file
        print("Should check for new file, etc.")
        fetched = true
        -- Should compile file
        if compileFiles and fetched then 
            node.compile(remoteFile)
        end
    end
end

local function autoStartIfDefined()
    if autoStart then
        local withExtension
        if compileFiles then withExtension = autoStart .. ".lc" else withExtension = autoStart .. ".lua" end
        dofile(withExtension)
    else
        print("- No autoStart file defined, you will need to manually run a program")
    end
end

remoteUpdateAuto()
autoStartIfDefined()
