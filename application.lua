-- file : application.lua
local module = {}
m = nil

--live_topic = config.ENDPOINT .. "live/" .. config.ID

-- Sends a simple ping to the broker
local function send_ping()
    topic = config.ENDPOINT .. "ping"
    payload = "id=" .. config.ID
    m:publish(topic, payload, 0, 0, function(conn)
        print("Published[" .. topic .. "]: " .. payload)
    end)
end

--
local function set_live()
    payload = "online=" .. config.ID
    m:publish(config.LIVE, payload, 1, 1, function(conn)
        print("Set live[" .. config.LIVE .. "]: " .. payload)
    end)
end

-- Sends my id to the broker for registration
local function register_myself()
    topic = config.ENDPOINT .. config.ID
    m:subscribe(topic, 0, function(conn)
        print("Subscribed[" .. topic .. "]")
    end)
end

local function mqtt_start()
    -- init mqtt client without logins, keepalive timer 10s
    m = mqtt.Client(config.ID, 10)

    -- setup Last Will and Testament
    -- Broker will publish a message with qos = 1, retain = 1, data = "offline" 
    -- to topic "nodemcu/live/ID" if nodemcu doesn't send keepalive packet
    m:lwt(config.LIVE, "offline=" .. config.ID, 1, 1)

    -- register message callback beforehand
    m:on("connect", function(conn) print ("Connected") end)
    m:on("offline", function(conn) print ("Offline") end) -- TODO:reconnect MQTT
    m:on("message", function(conn, topic, data)
      if data ~= nil then
        print("Received[" .. topic .. "]: " .. data)
        -- do something, we have received a message
      end
    end)
    -- Connect to broker
    print("MQTT Connect : " .. config.HOST .. ":" .. config.PORT)
    m:connect(config.HOST, config.PORT, 0, function(con) 
        print("MQTT Connect Success!!")
        set_live()
        register_myself()
        -- And then pings each 5000 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 5000, 1, send_ping)
    end)

end

function module.start()
  print("MQTT start")
  mqtt_start()
end

return module
