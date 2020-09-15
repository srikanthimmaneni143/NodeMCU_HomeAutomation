# NodeMCU_HomeAutomation
To control the loads through the Mobile_APP with use of MQTT protocol. And also readback the status of the loads.
With this We can control the NodeMCU Lolin v3Esp8266Ex and used the MQTT protocol and Adafruit MQTT Broker.

Controlling of 4Loads and Reading the status of those loads has done

We have used the node.ping() inbuilt function in order to check whether the Internet is present or not, If Internet is not present then we hav$

Main_Application.lua is the MQTT related operations has implemented 
init.lua is the initialization of the WIFI and other related stuff.



Known Bugs: In init.lua file after disconnection of the wifi mqttClient:close() function is not closing.


Planning Feature:
1. To implement email sending with the reboot reason on every  reboot of the Device.
2. To Implement Control throgh the WIFI only if internet is not present and within the wifi range of Nodemcu Device. 
