
debug = false
json = require('json')
Count = 0

allowConnect = false
isConnected = false
Scroll_Lock = false
Update = true
cachedUsername = nil

-- Requierd parameter for Hue.
Dev = {devicetype = "Quinn"}
encodedDev = json.encode(Dev)
controlNames = {"On", "Off", "Preset1", "Preset2", "Preset3", "Preset4"}
-- Multicast address for discovering Hue IP.
hueDiscovery = "M-SEARCH * HTTP/1.1\nHost: 239.255.255.250:1900\nMan: 'ssdp:discover'\nST: hue:ecp\n\n"

HueHostName = (NamedControl.GetText("IP"))
Hue_State = NamedControl.GetValue("Hue")
Bri_State = NamedControl.GetValue("Bri")
Sat_State = NamedControl.GetValue("Sat")
NamedControl.SetValue('LED #1', 0)

-- Constants for on, off, preset colors.
Red = {on = true, sat = 255, bri = 255, hue = 0}
Orange = {on = true, sat = 255, bri = 255, hue = 5461}
Green = {on = true, sat = 255, bri = 255, hue = 16383}
Turquoise = {on = true, sat = 255, bri = 255, hue = 32766}
Blue = {on = true, sat = 255, bri = 255, hue = 38227}
Purple = {on = true, sat = 255, bri = 255, hue = 49149}
Pink = {on = true, sat = 255, bri = 255, hue = 54610}
Scarlet = {on = true, sat = 255, bri = 255, hue = 65532}
lightsOn = {on = true, sat = 100, bri = 175,hue = 60000}
lightsOff = {on = false}

-- UDP Response for IP Discovery
function HandleData(socket, packet)

    receivedIP, receivedPort = socket:GetSockName()
    NamedControl.SetText("IP", packet.Address)
end  

-- Creates a username token to be used throughout the script
function Response(Table, ReturnCode, Data, Error, Headers)

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
        NamedControl.SetText("Username", username)
        cachedUsername = NamedControl.GetText("Username")
    end
end

-- Check index value of premade selection drop down menus. 
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

-- Formats current value of Manual Selection faders.
function Custome_Color(Sat, Bri, Hue)
 
    local CustomColor = {on = true, sat = Sat, bri = Bri, hue = Hue}
    local encodedCustomColor = json.encode(CustomColor)
    return encodedCustomColor
end

-- Create URL's --

-- URL for getting new username.
function Create_Dev_URL()
      
    local New_Dev_Url = HttpClient.CreateUrl({
        Host = HueHostName,
        Query = {},
        Path = 'api'})
    return New_Dev_Url
end

-- URL for Pre sets.
function Create_Pre_Set_URL()

    if cachedUsername ~= nil then
        local Pre_Set_URL = HttpClient.CreateUrl({
            Host = HueHostName,
            Query = {},
            Path = 'api/'  .. cachedUsername .. '/groups/0/action'})
        return Pre_Set_URL
    end
end

-- URL for Manual Selection.
function Create_Custome_Color_URL()

    local Custome_Color_Url = HttpClient.CreateUrl({
        Host = HueHostName,
        Query = {},
        Path = 'api/'  .. cachedUsername .. '/groups/0/action'})
    return Custome_Color_Url
end

-- End Create URL's --

-- Sends the current valuer of Manual Selection faders.
function Send_Custome_Color()

    if cachedUsername ~= nil then
        -- Hue only accepts whole numbers. +0.5 to round numbers off.
        local Hue = (math.floor(NamedControl.GetValue("Hue")+0.5))
        local Bri = (math.floor(NamedControl.GetValue("Bri")+0.5))
        local Sat = (math.floor(NamedControl.GetValue("Sat")+0.5))

        HttpClient.Upload({
            Url = Create_Custome_Color_URL(),
            Data = Custome_Color(Sat, Bri, Hue),
            Method = 'PUT',
            EventHandler = Response})
    end
end

-- Stores/Sets values for On/Off. When off, values of faders are stored for recall.
function Store_Color(Hue, Sat, Bri)

    if NamedControl.GetPosition("Off") ~= 1 then
        lightsOn.hue = Hue
        lightsOn.sat = Sat
        lightsOn.bri = Bri
    end

    NamedControl.SetValue("Hue", Set_Fader.hue)
    NamedControl.SetValue("Sat", Set_Fader.sat)
    NamedControl.SetValue("Bri", Set_Fader.bri)
end

-- Set up for UDP Socket, only used for IP discovery.
MyUdp = UdpSocket.New()
MyUdp:Open(Device.LocalUnit.ControlIP, 0)
MyUdp.Data = HandleData
MyUdp:Send("239.255.255.250", 1900, hueDiscovery)

function TimerClick()

    Count = Count + 1
    
    cachedUsername = NamedControl.GetText("Username")
    HueHostName = NamedControl.GetText("IP")
    local Connect = NamedControl.GetValue("Connect")
    local Preset1Value =  NamedControl.GetValue("Colorlist1")
    local Preset2Value = NamedControl.GetValue("Colorlist2")
    local Preset3Value = NamedControl.GetValue("Colorlist3")
    local Preset4Value = NamedControl.GetValue("Colorlist4")
    local offlineConnectButton = NamedControl.GetValue("OfflineConnect")

    -- Encoded premade color options, On, Off. 
    if Update == true then
        encodedData = {
            json.encode(lightsOn),
            json.encode(lightsOff),
            json.encode(get_color(Preset1Value)),
            json.encode(get_color(Preset2Value)),
            json.encode(get_color(Preset3Value)),
            json.encode(get_color(Preset4Value))}
        Update = false
    end
   
    -- Establishes if allowed to connect.
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
            NamedControl.SetPosition("Discover", 0) 
        end

        if Connect == 1 then
            HttpClient.Upload({
                Url = Create_Dev_URL(HueHostName),
                Data = encodedDev,
                Method = 'POST',
                EventHandler = Response})
            NamedControl.SetPosition("Connect", 0)
        end

        -- Cycle through presets and grab their value.
        controlValues = {}

        for index,value in pairs(controlNames) do
            table.insert(controlValues, index, NamedControl.GetValue(value))
        end
 
        for index,value in pairs(encodedData) do
            if controlValues[index] == 1 and cachedUsername ~= nil then
                Update = true
                Set_Fader = json.decode(value)
                Store_Color(Set_Fader.hue, Set_Fader.sat, Set_Fader.bri)

                HttpClient.Upload({
                    Url = Create_Pre_Set_URL(),
                    Data = value,
                    Method = 'PUT',
                    EventHandler = Response})

                    Hue_State = NamedControl.GetValue("Hue")
                    Sat_State = NamedControl.GetValue("Sat")
                    Bri_State = NamedControl.GetValue("Bri")

                    NamedControl.SetPosition("On", 0)
                    NamedControl.SetPosition("Off", 0)
                    NamedControl.SetPosition("Preset1", 0)
                    NamedControl.SetPosition("Preset2", 0)
                    NamedControl.SetPosition("Preset3", 0)
                    NamedControl.SetPosition("Preset4", 0)
            end
        end

        if Count == 4 then
            Count = 0
        elseif Count == 3 then
            Scroll_Lock = false
        end

        if Hue_State ~= NamedControl.GetValue("Hue") and cachedUsername ~= nil and Scroll_Lock == false then
            Scroll_Lock = true
            Send_Custome_Color()
            Hue_State = NamedControl.GetValue("Hue")
            lightsOn.hue = (math.floor(Hue_State))
        end

        if Sat_State ~= NamedControl.GetValue("Sat") and cachedUsername ~= nil and Scroll_Lock == false then
            Scroll_Lock = true
            Send_Custome_Color()
            Sat_State = NamedControl.GetValue("Sat")
            lightsOn.sat = (math.floor(Sat_State))
        end

        if Bri_State ~= NamedControl.GetValue("Bri") and cachedUsername ~= nil and Scroll_Lock == false then
            Scroll_Lock = true
            Send_Custome_Color()
            Bri_State = NamedControl.GetValue("Bri")
            lightsOn.bri = (math.floor(Bri_State))
        end
    end
end

MyTimer = Timer.New()
MyTimer.EventHandler = TimerClick
MyTimer:Start(.5)