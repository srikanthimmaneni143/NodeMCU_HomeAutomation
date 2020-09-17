---*********************************************************************
wifi.setmaxtxpower(80);
wifi.sta.sethostname("NodeMCU");
wifi.setphymode(wifi.PHYMODE_B);

station_config={}
station_config[0] = {ssid='******',pwd='********',save=false,auto=true};
station_config[1] = {ssid='********',pwd='*********',save=false,auto=true};

--*********************************************************************
function MQTTCONNECT()
    mqttClient:connect(server, port, false,
    function(client)  --On Connection success It will execute
       MQTTConnection_state = true;
       if Debug_Console then
           print("Connected to Adafruit");
       end --- Debug console
       mqttClient:subscribe(subscribe_topic,0,function(cli) 
            if Debug_Console then
                print("Subsribe: OK");
            end --- Debug console

       end)
    end,
    function(client, reason) --On failure it will execute
     if Debug_Console then
      print("failed reason: " .. reason)
     end -- Debug
      if (reason == -5) then
        print("The internet Disconnected.");
        MQTTConnection_state = false;
        if(WIFI_Status ) then
            Ping_Timer:start();
        end
 --       WIFI_Status = false;
        -- Here Client connection is closing
        -- If the problem is with the WIFI immediately problem occurs
        --But if it is from wifi connected and internet not then it takes sometime 
      end
      if (reason == -3) then
        print("DNS LookUp Failed... Please check the server address.")
      end
      if (reason == 5) then
        print("Please Check the Given Username and Key.")
      end
      if (reason == 4) then
        print("The broker refused the specified username or password.")
      end
     end) --MQTT Connect function end
end     
--******************** STA Connected **********************************
 wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
  if Debug_Console then
    print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
    T.BSSID.."\n\tChannel: "..T.channel)
  end-- Debug console
  WIFI_Status     = true;
    Ping_Timer:start();
--  MQTTCONNECT();
--Connecting

end)
--************** END OF STA Connected  ******************************** 


-------****************************************************************
 wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 WIFI_Status     = false;
 if (MQTTConnection_state) then
    if Debug_Console then
        print("MQTTClient Closed"); 
    end-- Debug console
    MQTTConnection_state = false;
 end
 running, mode = Ping_Timer:state()
 if (running == true) then
    Ping_Timer:stop();
 end
 if Debug_Console then
 print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID.."\n\treason: "..T.reason)
 end-- Debug console
 Disconnect_Count = Disconnect_Count + 1;
 if(Disconnect_Count >= 50) then
     if (T.reason == 201)  then   --If Hotspot is not available then switch 2 second one
        WIFI_Number = bit.bxor(WIFI_Number, 1);
        wifi.sta.config(station_config[WIFI_Number])
        Disconnect_Count = 0;
     end
 end
 end)
---******************************************************************** 


 wifi.eventmon.register(wifi.eventmon.STA_AUTHMODE_CHANGE, function(T)
 print("\n\tSTA - AUTHMODE CHANGE".."\n\told_auth_mode: "..
 T.old_auth_mode.."\n\tnew_auth_mode: "..T.new_auth_mode)
 end)

 wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
 T.netmask.."\n\tGateway IP: "..T.gateway)
 end)

 wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function()
 print("\n\tSTA - DHCP TIMEOUT")
 end)

 wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T)
 print("\n\tAP - STATION CONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
 end)

 wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, function(T)
 print("\n\tAP - STATION DISCONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
 end)

 wifi.eventmon.register(wifi.eventmon.AP_PROBEREQRECVED, function(T)
 print("\n\tAP - PROBE REQUEST RECEIVED".."\n\tMAC: ".. T.MAC.."\n\tRSSI: "..T.RSSI)
 end)

 wifi.eventmon.register(wifi.eventmon.WIFI_MODE_CHANGED, function(T)
 print("\n\tSTA - WIFI MODE CHANGED".."\n\told_mode: "..
 T.old_mode.."\n\tnew_mode: "..T.new_mode)
 end)


function wifi_setmode_station()
    if(wifi.sta.config(station_config[WIFI_Number]) == true) then 
     if Debug_Console then
         print("WiFi: OK\n");
     end -- Debug console
     dofile("Main_Application.lua");
    end
--    wifi.sta.connect()  
--    wifi.sta.autoconnect(1)
end

wifi_setmode_station()



