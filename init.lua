MQTTConnection_state = false ;
PINGTimer_Presence  = false;
WIFI_Number     = 0 ;
Disconnect_Count= 0;


-------****************************************************************
 wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 if ((MQTTConnection_state == true) and (mqttClient:close() == true)) then
    print("MQTTClient Closed");
    MQTTConnection_state = false;
 end
 if (PINGTimer_Presence == true ) then
    pingtimer:unregister();
    PINGTimer_Presence = false;
 end
 print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID.."\n\treason: "..T.reason)
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

--******************** STA Connected **********************************
 wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
 print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID.."\n\tChannel: "..T.channel)
 Disconnect_Count = 0;
--[[ tmr.create():alarm(800, tmr.ALARM_SINGLE, function()
 --Connecting to mqtt broker
 mqttClient:connect(server, port, false,Connection_Established,Connection_Fail);
 end)]]
    pingtimer = tmr.create();
    if pingtimer then
        Timer_Presence = true;
--        pingtimer:alarm(10000, tmr.ALARM_AUTO, Ping_Callback())
        pingtimer:alarm(10000, tmr.ALARM_AUTO, function()
        net.ping("www.nodemcu.com",1, function (b, ip, sq, tm) 
        if ip then 
---If Internet is present then execute this
            if(b == 32) then 
            print("Internet: OK");
            if not(MQTTConnection_state) then
              mqttClient:connect(server, port, false,Connection_Established,Connection_Fail);    
            end
---- If internet is not present then execte this             
            else
              print("Internet: Not OK");   
              if ((mqttClient:close() == true) and (MQTTConnection_state == true)) then
                print("MQTTClient Closed");
                MQTTConnection_state = false;
              end
            end--Internet presence 
        end--ip is present    
        end)--ping callback function
    end)

        print("Timer created");
    end    
 end) --function end

--************** END OF STA Connected  ******************************** 

--*********************************************************************
wifi.setmaxtxpower(80);
wifi.sta.sethostname("NodeMCU");
wifi.setphymode(wifi.PHYMODE_B);
--*********************************************************************

--Restart data recovery
RestartUpdate_Data  = 0x0000;   -- This is the data updates and stores in RTC to revert back to previous switch state
RestartUpdate_Address  = 127;     --The location that where the above data stores in RTC memory
--*********************************************************************

-- adafruit server details
server          = "io.adafruit.com"
port            = 1883
publish_topic   = "sri8352/feeds/srikanth.readback" -- e.g. "Nivya151/feeds/potValue"
subscribe_topic = "sri8352/feeds/srikanth.home" -- e.g. "Nivya151/feeds/ledBrightness"
aio_username    = "sri8352"           -- e.g. "Nivya151"  
aio_key         = "aio_uThs68F7phVYFewXHb2TcRiTJ3y2"
client_id       = "SriNodemcu"
Keep_alive      = 10


--*********************************************************************

--***************** Respective bit positions **************************
LightBit_Pos = 0;
TvBit_Pos = 1;
BedLampBit_Pos = 2;
FanBit_Pos = 3;

--****************Pins defining to control relays  *********************
TVpin = 1;
Lightpin = 2;
Bedlamppin = 5;
Fanpin = 6;
--**********************************************************************
--Setting the pins mode to OUTPUT mode and make the relay to switch off
gpio.mode(TVpin, gpio.OUTPUT);
gpio.write(TVpin, 1);
gpio.mode(Lightpin, gpio.OUTPUT);
gpio.write(Lightpin,1);
gpio.mode(Bedlamppin, gpio.OUTPUT);
gpio.write(Bedlamppin, 1);
gpio.mode(Fanpin, gpio.OUTPUT);
gpio.write(Fanpin, 1);

--**********Reading the RTC data from memory  *************************
RestartUpdate_Data = rtcmem.read32(RestartUpdate_Address);

--*********************************************************************
-- print("DATA is: ".. RestartUpdate_Data);
if(RestartUpdate_Data > 15) then 
    rtcmem.write32(RestartUpdate_Address, 0x0000);
    RestartUpdate_Data = rtcmem.read32(RestartUpdate_Address);
end
-- print("DATA is: ".. RestartUpdate_Data);
--*********************************************************************

--*********************************************************************
-- If rtc reading has data set then it will turn the respective gpio 
if (bit.isset(RestartUpdate_Data, LightBit_Pos) == true) then
gpio.write(Lightpin, 0);
else
gpio.write(Lightpin, 1);
end
if (bit.isset(RestartUpdate_Data, TvBit_Pos) == true) then
gpio.write(TVpin, 0);
else
gpio.write(TVpin, 1);
end
if (bit.isset(RestartUpdate_Data, BedLampBit_Pos) == true) then
gpio.write(Bedlamppin, 0);
else
gpio.write(Bedlamppin, 1);
end
if (bit.isset(RestartUpdate_Data, FanBit_Pos) == true) then
gpio.write(Fanpin, 0);
else
gpio.write(Fanpin, 1);
end
--*************** END of Setup Basics *********************************


--***Actual init file execution starts from this function**************
function startup()
--------------------------------------------------------------
station_config={}
station_config[0] = {ssid='SrI',pwd='12345678',save=false,auto=true};
station_config[1] = {ssid='Kalavathi',pwd='9948838710',save=false,auto=true};
--station_config2=
wifi.setmode(wifi.STATION,true)

    if(wifi.sta.config(station_config[WIFI_Number]) == true) then 
     print("WiFi: OK\n");
     dofile("Main_Application.lua");
    end
end
--**********************  END *****************************************

--********* This file is init.lua  ************************************
local IDLE_AT_STARTUP_MS = 800;
if not tmr.create():alarm(IDLE_AT_STARTUP_MS, tmr.ALARM_SINGLE, startup)
then
  print("Oops! failed on startup:)")
end
--*********************** END  ***************************************


--This code prints the reset reason of last
_, reset_reason = node.bootreason()
if reset_reason == 0 then print("Power ON!") end
if reset_reason == 1 then print("hardware watchdog reset!") end
if reset_reason == 2 then print("exception reset!") end
if reset_reason == 3 then print("software watchdog reset!") end
if reset_reason == 4 then print("software restart!") end
if reset_reason == 5 then print("wake from deep sleep!") end
if reset_reason == 6 then print("external reset!") end

