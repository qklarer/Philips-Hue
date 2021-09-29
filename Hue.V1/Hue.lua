json = require('json')

HueDiscovery = "M-SEARCH * HTTP/1.1\nHost: 239.255.255.250:1900\nMan: 'ssdp:discover'\nST: roku:ecp\n\n"




function HandleData(socket, packet)
  --Info about receiving socket and packet 
  print("Socket ID: " .. socket.ID)
  receivedIP, receivedPort = socket:GetSockName()
  print("Socket IP: " .. receivedIP)
  print("Socket Port: " .. receivedPort)
  print("Packet IP: " .. packet.Address)       
  print("Packet Port: " .. packet.Port)
  --Do stuff with the received packet    
  print("Packet Data: \r" .. packet.Data)
end  

MyUdp = UdpSocket.New()
MyUdp:Open(Device.LocalUnit.ControlIP, 0)
MyUdp.Data = HandleData
MyUdp:Send("239.255.255.250", 1900, HueDiscovery)

--[[function Response(Table, ReturnCode, Data, Error, Headers)
  url =  HttpClient.CreateUrl( {
                 Host = "https://192.168.2.20",
                 Query = {}, 
                 Port = {},
                 Path = 'api/lights/1/state'})
              --   print(url)
  end]]
  
  function Response( ReturnCode, Data, Error, Headers)
    --print(string.format("URL requested = '%s'.", Table.Url))
    print(Data)
    print(ReturnCode)

    if (200 == ReturnCode or ReturnCode == 201) then
      print("Success!")
      print(string.format("Data returned = '%s'", Data))
    else print("no")
    
    end
    

  end
  Response()
  test2 = {username = "buttsniffer", devicetype = "some AV shit"}
  encodedString2 = json.encode(test2)
  print(encodedString2)
  
  if true then
  
  end

test = {on = false} --sat = 254, bri = 254,hue = 10000}
encodedString = json.encode(test)
print(encodedString)

--HttpClient.Upload({ Url = "http://192.168.2.20/api", Data= encodedString2})
 -- HttpClient.Upload ({Url = "http://192.168.2.20/api/buttsniffer/lights/1",
  --  Data = encodedString,
  --  EventHandler = Response
  --  })

    



if true then
  HttpClient.Upload({ Url = "http://t/mq0cr-1610473799/post", Data = encodedString, Method = "POST"})
  print("posted")
  
end
           