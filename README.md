# wifiledlua
- Original author: James Burton

A WiFi LED controller for the NodeMCU written in Lua, with web-server, end-user configuration and MQTT communication for remote control

# Recommended Tools
* Node Flasher (used to flash latest firmware, or restore a board from Arduino deployment)
* ESPlorer (current the simplest IDE and deployment GUI available)

# Libraries Used
* tmr (Timer library, used for animation loops)
* enduser_setup (Enables a wifi-configuration web-server and settings storage)
* ws2812 (Library for managing the LED strip)
* net (Used for self-served web-interface)
* mqtt (Used for remtoe control messaging/communications)
