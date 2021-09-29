
json = require('json')
hueDiscovery = "M-SEARCH * HTTP/1.1\nHost: 239.255.255.250:1900\nMan: 'ssdp:discover'\nST: hue:ecp\n\n"


test = {on = false, sat = 254, bri = 254,hue = 10000}
encodedString = json.encode(test)
--{"on":true, "sat":254, "bri":254,"hue":10000}
print(encodedString)


function Response(Table, ReturnCode, Data, Error, Headers)
   url =  HttpClient.CreateUrl( {
                  Host = "https://192.168.2.20",
                  Query = {}, 
                  Port = {},
                  Path = 'api/lights/1/state'})
                  print(url)

                 
                HttpClient.Upload({ Url = url,
                                    User = "Cx94qeTsKx-boCGGki4kdp5E-BuJyyHMG3DE8ZYN",
                                    Data = encodedString,
                                    Method = PUT,
                                    EventHandler = Response })  
                                    if (200 == ReturnCode or ReturnCode == 201) then
                                      print("Good")
                               else
                                    print("Bad")
                               end 
                                  if true then
                                    print(url)
                end
end
              Response()
                
function HandleData(socket, packet)

    --Info about receiving socket and packet 
  --  print("Socket ID: " .. socket.ID)
    receivedIP, receivedPort = socket:GetSockName()
 --   print("Socket IP: " .. receivedIP)
  --  print("Socket Port: " .. receivedPort)
  --  print("Packet IP: " .. packet.Address)       
  --  print("Packet Port: " .. packet.Port)
    --Do stuff with the received packet    
   -- print("Packet Data: \r" .. packet.Data)

   hueIP = packet.Address
   print(hueIP)

end  

MyUdp = UdpSocket.New()
MyUdp:Open(Device.LocalUnit.ControlIP, 0)
MyUdp.Data = HandleData
--MyUdp:Send("239.255.255.250", 1900, hueDiscovery)


debug = true
json = require('json')
rokuPort = 8060
timerMultiplier = 4
timerCounter = 0
allowConnect = false
isConnected = false


--Creates URL to use through Script
--[[function rokuKeyPress(keyValue, Host, Port)
       return HttpClient.CreateUrl( {
                     Host = rokuHostName,
                     Query = {}, 
                     Port = rokuPort,
                     Path = 'keypress/' .. keyValue})    
end]]

--Turns LED on or off based on successful HTTP Status Code returned
--[[function Response(Table, ReturnCode, Data, Error, Headers)
       url = HttpClient.CreateUrl( {
                     Host = rokuHostName,
                     Query = {}, 
                     Port = rokuPort, })
                     
end]]




HueDiscovery = "M-SEARCH * HTTP/1.1\nHost: 239.255.255.250:1900\nMan: 'ssdp:discover'\nST: roku:ecp\n\n"

 



function TimerClick()  
       rokuHostName = (NamedControl.GetText("IP"))   
       offlineConnectButton = NamedControl.GetValue("ButtonOfflineConnect")
 
    --establish if allowed to connect
   if offlineConnectButton == 1 and Device.Offline then
        allowConnect = true
        NamedControl.SetPosition("OfflineConnect", 1)
    elseif Device.Offline == false then
        allowConnect = true
        NamedControl.SetPosition("OfflineConnect", 1)
    else
        allowConnect = false
        NamedControl.SetPosition("OfflineConnect", 0)
    end
    
    test = {on = false, sat = 254, bri = 254,hue = 10000}
    encodedString = json.encode(test)
    --{"on":true, "sat":254, "bri":254,"hue":10000}
    print(encodedString)
    
    
    function Response(Table, ReturnCode, Data, Error, Headers)
       url =  HttpClient.CreateUrl( {
                      Host = "https://192.168.2.20",
                      Query = {}, 
                      Port = 8060,
                      Path = 'api/lights/1/state'})
                      print(url)
    
                     
                    HttpClient.Upload({ Url = url,
                                        User = "Cx94qeTsKx-boCGGki4kdp5E-BuJyyHMG3DE8ZYN",
                                        Data = encodedString,
                                        Method = PUT,
                                        EventHandler = Response })  
end 
end
       timerCounter = timerCounter + 1

       if timerCounter >= timerMultiplier then
              HttpClient.Download({ Url = url, EventHandler = Response  })
              if Device.Offline == true then
                     NamedControl.SetPosition("LED #1", 0)
              else
                     NamedControl.SetPosition("LED #1", 1)
              end
       
       
              timerCounter = 0
       end



MyTimer = Timer.New()
MyTimer.EventHandler = TimerClick
MyTimer:Start(.5)




