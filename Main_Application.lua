
-- init mqtt client with logins, keepalive timer 10s
mqttClient = mqtt.Client(client_id, Keep_alive , aio_username, aio_key)

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
    if (data == "?Are you connected?") then
        mqttClient:publish(publish_topic, ":Yes, Iam:" , 0, 0, function(client)     
          if Debug_Console then
           print("Reply for the request of Connection status "); 
          end -- -- Debug console
        end)
    end
    if (data == "?Send me the status of all pins?") then
        str = ":Node pins status:" ;
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

--Callback function on Connection establish
function Connection_Established(client)
       if Debug_Console then
        print("MQTT Broker Connection: OK");
       end--- Debug console
       MQTTConnection_state = true;
       mqttClient:subscribe(subscribe_topic,0,function(cli) 
       if Debug_Console then
         print("Subsribe: OK");
       end --- Debug console
       end)-- Function 
end

 --On failure it will execute
function Connection_Fail(client, reason)
--      print("CLient:"..client,"failed reason: " .. reason)
      MQTTConnection_state = false;
end



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



