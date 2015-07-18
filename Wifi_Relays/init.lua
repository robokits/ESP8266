--Small demo of internet/network controlled relay using ESP8266 (ESP-01) module and 2 channel optoisolated relay board
--Made by Sandeep Vaidya @ Robokits India - http://www.robokits.co.in for demo.

--Configure relay ouutput pins, pins are floating and relay opto needs ground to be activated. So pins are kept high on startup.
Relay1 = 3
Relay2 = 4
gpio.mode(Relay1, gpio.OUTPUT)
gpio.write(Relay1, gpio.HIGH);
gpio.mode(Relay2, gpio.OUTPUT)
gpio.write(Relay2, gpio.HIGH);

wifi.setmode(wifi.STATION) --Set network mode to station to connect it to wifi router. You can also set it to AP to make it a access point allowing connection from other wifi devices.

--Set a static ip so its easy to access
cfg = {
    ip="192.168.2.87",
    netmask="255.255.255.0",
    gateway="192.168.2.15"
  }
wifi.sta.setip(cfg)

--Your router wifi network's SSID and password
wifi.sta.config("Robokits India","45&Dmdk#24Ne!")
--Automatically connect to network after disconnection
wifi.sta.autoconnect(1)
print ("\r\n")
--Print network ip address on UART to confirm that network is connected
print(wifi.sta.getip())
--Create server and send html data, process request from html for relay on/off.
srv=net.createServer(net.TCP)
srv:listen(80,function(conn) --change port number if required. Provides flexibility when controlling through internet.
    conn:on("receive", function(client,request)
        local html_buffer = "";
        local html_buffer1 = "";
		
		
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end

		html_buffer = html_buffer.."<html><head><meta http-equiv=\"Content-Language\" content=\"en-us\"><meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-1252\">";
		html_buffer = html_buffer.."<title>Robokits IOT Server</title></head><body><p><b><font face=\"Arial Black\" size=\"6\" color=\"#0000FF\"><marquee behavior=\"alternate\" bgcolor=\"#FFFF00\">ROBOKITS IOT SERVER </marquee></font></b></p>";
		html_buffer = html_buffer.."<table border=\"1\" width=\"11%\" bordercolorlight=\"#000000\" bordercolordark=\"#008000\" height=\"137\"><tr><td style=\"border-style: solid; border-width: 1px\" width=\"91\" bgcolor=\"#CC6600\" align=\"center\"><b>";
		html_buffer = html_buffer.."<font face=\"Verdana\" size=\"2\" color=\"#FFFF99\">RELAY1</font></b></td><td style=\"border-style: solid; border-width: 1px\" bgcolor=\"#CC6600\" align=\"center\"><b><font face=\"Verdana\" size=\"2\" color=\"#FFFF99\">RELAY2</font></b></td></tr>";
		html_buffer1 = html_buffer1.."<tr><td style=\"border-style: solid; border-width: 1px\" width=\"91\" align=\"center\"><a href=\"?pin=ON1\"><button><font face=\"Verdana\"><b>ON</button></b></font></a></td><td style=\"border-style: solid; border-width: 1px\" align=\"center\"><a href=\"?pin=ON2\"><button><font face=\"Verdana\"><b>ON</button></b></font></a></td></tr>";
		html_buffer1 = html_buffer1.."<tr><td style=\"border-style: solid; border-width: 1px\" width=\"91\" align=\"center\"><a href=\"?pin=OFF1\"><button><font face=\"Verdana\"><b>OFF</button></b></font></a></td><td style=\"border-style: solid; border-width: 1px\" align=\"center\"><a href=\"?pin=OFF2\"><button>";
		html_buffer1 = html_buffer1.."<font face=\"Verdana\"><b>OFF</button></b></font></a></td></tr></table><p><b><font face=\"Verdana\">Visit our website : <a href=\"http://www.robokits.co.in\">http://www.robokits.co.in </a></font></b></p></body></html>";
	
	
        local _on,_off = "",""
        if(_GET.pin == "ON1")then
              gpio.write(Relay1, gpio.LOW);
        elseif(_GET.pin == "OFF1")then
              gpio.write(Relay1, gpio.HIGH);
        elseif(_GET.pin == "ON2")then
              gpio.write(Relay2, gpio.LOW);
        elseif(_GET.pin == "OFF2")then
              gpio.write(Relay2, gpio.HIGH);
        end
        --Buffer is sent in smaller chunks as due to limited memory ESP8266 cannot handle more than 1460 bytes of data.
		client:send(html_buffer);
        client:send(html_buffer1);
        client:close();
        collectgarbage();
    end)
end)
