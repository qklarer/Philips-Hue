
debug = true
json = require('json')
timerMultiplier = 4
timerCounter = 0
allowConnect = false
isConnected = false
cachedUsername = nil
NamedControl.SetValue('LED #1', 0)

--Constants for on and off, On sets it to a very gental color and brightness
Red = {on = true, sat = 255, bri = 200, hue = 0}
Orange = {on = true, sat = 255, bri = 200, hue = 5461}
Green = {on = true, sat = 255, bri = 200, hue = 16383}
Turquoise = {on = true, sat = 255, bri = 200, hue = 32766}
Blue = {on = true, sat = 255, bri = 200, hue = 38227}
Purple = {on = true, sat = 255, bri = 200, hue = 49149}
Pink = {on = true, sat = 255, bri = 200, hue = 54610}
Scarlet = {on = true, sat = 255, bri = 200, hue = 65532}
lightsOn = {on = true, sat = 100, bri = 100, hue = 60000}
lightsOff = {on = false}

Dev = {devicetype = "Quinn"}
encodedDev = json.encode(Dev)

controlNames = {"On", "Off", "Preset1", "Preset2", "Preset3", "Preset4"}

hueDiscovery = "M-SEARCH * HTTP/1.1\nHost: 239.255.255.250:1900\nMan: 'ssdp:discover'\nST: hue:ecp\n\n"

function HandleData(socket, packet)

   receivedIP, receivedPort = socket:GetSockName()
   NamedControl.SetText("IP", packet.Address)
end  

-- Creates a username token to be used through the script
function Response(Table, ReturnCode, Data, Error, Headers)
   
   NamedControl.SetText("Feedback Data", Data)

   if debug then 
      print(Data) 
      print(Table)
      print(ReturnCode)
      print(Error)
      print(Headers)
   end

   if (200 == ReturnCode or ReturnCode == 201) then
      NamedControl.SetValue('LED #1', 1)
   else 
      NamedControl.SetValue('LED #1', 0)
   end
    
   local DataTable = json.decode(Data)
   username = (DataTable[001]['success']['username'])

   if (username ~= nil) then
      cachedUsername = username
   end
end
   
function get_color(lookup_value)

    if lookup_value == 0 then
        return Red
     elseif lookup_value == 1 then
        return Orange
     elseif lookup_value == 2 then
        return Green
     elseif lookup_value == 3 then
        return Turquoise
     elseif lookup_value == 4 then
        return Blue
     elseif lookup_value == 5 then
        return Purple
     elseif lookup_value == 6 then
        return Pink
     elseif lookup_value == 7 then
        return Scarlet
     end
end

function Create_Dev_URL(IP)
      
   local New_Dev_Url = HttpClient.CreateUrl({
      Host = HueHostName,
      Query = {},
      Path = 'api'})
   return New_Dev_Url
end

function Create_Pre_Set_URL(IP)
   
   local Pre_Set_URL = HttpClient.CreateUrl({
      Host = IP,
      Query = {},
      Path = 'api/'  .. cachedUsername .. '/groups/0/action'})
   return Pre_Set_URL
end

function Create_Custome_Color_URL(IP)

   local Custome_Color_Url = HttpClient.CreateUrl({
      Host = HueHostName,
      Query = {},
      Path = 'api/'  .. cachedUsername .. '/groups/0/action'})
   return Custome_Color_Url
end

function Premade_Color()


end

function Custome_Color(Sat, Bri, Hue)
 
   local CustomColor = {on = true, sat = Sat, bri = Bri, hue = Hue}
   local encodedCustomColor = json.encode(CustomColor)
   return encodedCustomColor
end

MyUdp = UdpSocket.New()
MyUdp:Open(Device.LocalUnit.ControlIP, 0)
MyUdp.Data = HandleData
MyUdp:Send("239.255.255.250", 1900, hueDiscovery)


function TimerClick()

   Upload = NamedControl.GetValue("Upload")
   Download = NamedControl.GetValue("Download")
   NewDev = NamedControl.GetValue("NewDev")
   On = NamedControl.GetValue("On")
   Off = NamedControl.GetValue("Off")
   Preset1 = NamedControl.GetValue("Preset1")
   Preset2 = NamedControl.GetValue("Preset2")
   Preset1Value =  NamedControl.GetValue("Colorlist1")
   Preset2Value = NamedControl.GetValue("Colorlist2")
   Preset3Value = NamedControl.GetValue("Colorlist3")
   Preset4Value = NamedControl.GetValue("Colorlist4")
   HueHostName = (NamedControl.GetText("IP"))
   Hue = (math.floor(NamedControl.GetValue("Hue")+0.5))
   Bri = (math.floor(NamedControl.GetValue("Bri")+0.5))
   Sat = (math.floor(NamedControl.GetValue("Sat")+0.5))
   offlineConnectButton = NamedControl.GetValue("ButtonOfflineConnect")
   update = NamedControl.GetValue("Update")

   --Premade color options
   Preset1Color = get_color(Preset1Value)
   Preset2Color = get_color(Preset2Value)
   Preset3Color = get_color(Preset3Value)
   Preset4Color = get_color(Preset4Value)
   
   encodedData = {
      json.encode(lightsOn),
      json.encode(lightsOff),
      json.encode(Preset1Color),
      json.encode(Preset2Color),
      json.encode(Preset3Color),
      json.encode(Preset4Color)}

   timerCounter = timerCounter + 1

   --Establishes if allowed to connect
   if offlineConnectButton == 1 and Device.Offline then
      allowConnect = true
   elseif Device.Offline == false then
      allowConnect = true
   else
      allowConnect = false
   end

   if allowConnect then

      if NamedControl.GetPosition("Discover") == 1 then
         MyUdp:Send("239.255.255.250", 1900, hueDiscovery)
      end
      -- cycle through the controls (on, off, preset1, etc..) and grab their value
      controlValues = {}
      for index,value in ipairs(controlNames) do
         table.insert(controlValues, index, NamedControl.GetValue(value))
      end

      for index,value in ipairs(encodedData) do
         if controlValues[index] == 1 and cachedUsername ~= nil then

            HttpClient.Upload({
               Url = Create_Pre_Set_URL(HueHostName),
               Data = value,
               Method = 'PUT',
               EventHandler = Response})
         end
      end

      if NewDev == 1 then
         HttpClient.Upload({
            Url = Create_Dev_URL(HueHostName),
            Data = encodedDev,
            Method = 'POST',
            EventHandler = Response})
      end

      --checks online status of composer at a slower rate then the TimerClick
     -- if timerCounter >= timerMultiplier  then
         if update == 1 and cachedUsername ~= nil then
                        
            HttpClient.Upload({
               Url = Create_Custome_Color_URL(HueHostName),
               Data = Custome_Color(Sat, Bri, Hue),
               Method = 'PUT',
               EventHandler = Response})
      
         --timerCounter = 0
         NamedControl.SetPosition("Update", 0)
      end

         NamedControl.SetPosition("On", 0)
         NamedControl.SetPosition("Off", 0)
         NamedControl.SetPosition("Preset1", 0)
         NamedControl.SetPosition("Preset2", 0)
         NamedControl.SetPosition("Preset3", 0)
         NamedControl.SetPosition("Preset4", 0)
         NamedControl.SetPosition("NewDev", 0)
         NamedControl.SetPosition("Discover", 0) 
   end
end

MyTimer = Timer.New()
MyTimer.EventHandler = TimerClick
MyTimer:Start(.5)
