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

# Hardware requirements
* NodeMCU (or similar ESP8266 board with appropriate power board or features)
* 3.3V - 5V voltage convertor
* WS8212 LED strip
* Wires, connectors, pin board, case, other general items that can be adapted and customised

# Build Notes
* The ws8212 library is hard-coded to pin D4, so this must be mapped to the 3.3V voltage convertor input
* The data pin from the ws8212 is connected to the 5V output from the volatage convertor
* 5V power should be supplied to the appropriate pins of the LED strip
* The node MCU can be powered via the USB during programming, or via the 5V power pins from the same rail as the LED strip once delpoyed.  I use a hacked down USB cable to provide my 5V power input.