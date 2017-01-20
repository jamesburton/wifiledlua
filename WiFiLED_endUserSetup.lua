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
