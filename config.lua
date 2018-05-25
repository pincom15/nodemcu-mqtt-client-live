-- file : config.lua
local module = {}

module.SSID = {}
module.SSID["INPUT_SSID"] = "INPUT_PASSWORD"

module.HOST = "INPUT_MQTT_SERVER_ADDRESS"
module.PORT = 1883
module.ID = node.chipid()

module.ENDPOINT = "nodemcu/"
module.LIVE = module.ENDPOINT .. "live/" .. module.ID

return module
