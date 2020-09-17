MQTTConnection_state = false ;
WIFI_Status     = false;
WIFI_Number     = 0 ;
Disconnect_Count= 0;
Debug_Console   = true;
Ping_Timer      = nil;

-- adafruit server details
server          = ""
port            = 1883
publish_topic   = "" -- e.g. "Nivya151/feeds/potValue"
subscribe_topic = "" -- e.g. "Nivya151/feeds/ledBrightness"
aio_username    = ""           -- e.g. "Nivya151"  
aio_key         = ""
client_id       = ""
Keep_alive      = 60
--*********************************************************************

--Restart data recovery
RestartUpdate_Data  = 0x0000;   -- This is the data updates and stores in RTC to revert back to previous switch state
RestartUpdate_Address  = 127;     --The location that where the above data stores in RTC memory
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



--Actual init file execution starts from this function
function startup()
   dofile("WiFI_Setup.lua");
   Ping_Timer = tmr.create();
   Ping_Timer:register(3000, tmr.ALARM_AUTO, Ping_Response);
end


--This file is init.lua
local IDLE_AT_STARTUP_MS = 1000;
if not tmr.create():alarm(IDLE_AT_STARTUP_MS, tmr.ALARM_SINGLE, startup)
then
  print("Oops! failed to start:)")
end


--This code prints the reset reason of last
_, reset_reason = node.bootreason()
if reset_reason == 0 then print("Power ON!") end
if reset_reason == 1 then print("hardware watchdog reset!") end
if reset_reason == 2 then print("exception reset!") end
if reset_reason == 3 then print("software watchdog reset!") end
if reset_reason == 4 then print("software restart!") end
if reset_reason == 5 then print("wake from deep sleep!") end
if reset_reason == 6 then print("external reset!") end

