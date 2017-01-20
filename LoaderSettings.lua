-- Put Loader Settings in here
-- Path to update host instance (see https://github.com/jamesburton/updatehost)
remoteUpdateHost = "https://luaupdatehost.azurewebsites.net"
remoteUpdatePath = "/projectFiles/"
remoteUpdateProject = "WiFiLED"
remoteUpdateFiles = {"CompileAndRunWiFiLED.lua", "WiFiLED.lua", "WiFiLED_ws2812.lua", "WiFiLED_webServer.lua", "WiFiLED_mqtt.lua"}
--autoStart = nil
compileFiles = true
autoUpdate = false
autoStart = "CompileAndRunWiFiLED"  -- NB: .lc or .lua will be added

