
-- init mqtt client with logins, keepalive timer 10s
mqttClient = mqtt.Client(client_id, Keep_alive , aio_username, aio_key);

mqttClient:lwt(publish_topic, "Unexpected offline", 0, 0);

mqttClient:on("connect", function(client) 
    if Debug_Console then
        print ("Client connected");
    end -- -- Debug console
end)

function Ping_Response()
    net.ping("8.8.4.4",1, function (b, ip, sq, tm) 
        if ip then
            if (b  > 0) then
                MQTTCONNECT();
                Ping_Timer:stop();
            end  
            print(("%d bytes from %s, icmp_seq=%d time=%dms"):format(b, ip, sq, tm)) else print("Invalid IP address") end 
    end) 

end

--If device got disconnected
mqttClient:on("offline", function(client) 
    if Debug_Console then
        print ("Client offline");   
    end -- -- Debug console
    MQTTConnection_state = false;
    if WIFI_Status then
    Ping_Timer:start();
    end
end)

-- on message receive event
mqttClient:on("message", function(client, topic, data) 
--  print(topic .. ":" ) 
  if data ~= nil then
    if Debug_Console then
        print("received : ", data);
    end -- -- Debug console
    if (data == "LIGHT_OFF:HOME") then
        gpio.write(Lightpin, 1);
        RestartUpdate_Data = bit.clear(RestartUpdate_Data, LightBit_Pos)
    end
    if (data == "LIGHT_ON:HOME") then
        gpio.write(Lightpin, 0);
        RestartUpdate_Data = bit.set(RestartUpdate_Data, LightBit_Pos)
    end
    if (data == "TV_OFF:HOME") then
        gpio.write(TVpin, 1);
        RestartUpdate_Data = bit.clear(RestartUpdate_Data, TvBit_Pos)
    end
    if (data == "TV_ON:HOME") then
        gpio.write(TVpin, 0);
        RestartUpdate_Data = bit.set(RestartUpdate_Data, TvBit_Pos)
    end
    if (data == "NIGHTLIGHT_OFF:HOME") then
        gpio.write(Bedlamppin, 1);
        RestartUpdate_Data = bit.clear(RestartUpdate_Data, BedLampBit_Pos)
    end
    if (data == "NIGHTLIGHT_ON:HOME") then
        gpio.write(Bedlamppin, 0);
        RestartUpdate_Data = bit.set(RestartUpdate_Data, BedLampBit_Pos)
    end
    if (data == "FAN_OFF:HOME") then
        gpio.write(Fanpin, 1);
        RestartUpdate_Data = bit.clear(RestartUpdate_Data, FanBit_Pos)
    end
    if (data == "FAN_ON:HOME") then
        gpio.write(Fanpin, 0);
        RestartUpdate_Data = bit.set(RestartUpdate_Data, FanBit_Pos)
    end
    if (data == "ping?") then
        mqttClient:publish(publish_topic, "?OK" , 0, 0, function(client)     
          if Debug_Console then
           print("Reply for the request of Connection ping "); 
          end -- -- Debug console
        end)
    end
    if (data == "Status_Please?") then
        str = "?Status_Back" ;
--Light
        if(gpio.read(Lightpin) == 1) then
        str = str .. ':LIGHT_OFF:' ;
        else
        str = str .. ':LIGHT_ON:' ;
        end
--TV
        if(gpio.read(TVpin) == 1) then
        str = str .. ':TV_OFF:' ;
        else
        str = str .. ':TV_ON:' ;
        end
--Fan        
        if(gpio.read(Fanpin) == 1) then
        str = str .. ':FAN_OFF:' ;
        else
        str = str .. ':FAN_ON:' ;
        end
--Night Lamp        
        if(gpio.read(Bedlamppin) == 1) then
        str = str .. ':NIGHTLIGHT_OFF:' ;
        else
        str = str .. ':NIGHTLIGHT_ON:' ;
        end
        
        mqttClient:publish(publish_topic, str , 0, 0, function(client) 
           if Debug_Console then
            print("Asking for the status of pins and sent is '"..str.."'"); 
           end--- Debug console
        end)
    end
  
  end --if main
  rtcmem.write32(RestartUpdate_Address, RestartUpdate_Data);
end)--Message receive event function

--Support funcitons
function makeClientid() 
  local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  local length = 10
  local randomString = ''
  math.randomseed(os.time());
  charTable = {}
  for c in chars:gmatch"." do
    table.insert(charTable, c)
  end

  for i = 1, length do
    randomString = randomString .. charTable[math.random(1, #charTable)]
  end  
  return randomString;
end



