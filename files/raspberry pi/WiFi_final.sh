#!/bin/bash

i=0
o=0
count=0

while true
do

  ping 8.8.8.8 -c1 -W0.2
  
  if [ $? -eq 0 ];
  then
    echo "Script just booted" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    echo `date` >> log_WiFi_"$(date +"%d-%m-%y")".txt

    wg-quick up piuser
    
    if [ $? -eq 0 ];
    then
      echo "VPN successfully on" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    else
      echo "VPN did not turn on due to something" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    fi
    
    sleep 2
    
    screen -dm -S cam /home/pi/camera.sh
    
    if [ $? -eq 0 ];
    then
      echo "Camera successfully on" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    else
      echo "Camera did not turn on due to something" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    fi
    
    sleep 2
    
    screen -dm -S udp python3 /home/pi/udpServer.py
    
    if [ $? -eq 0 ];
    then
      echo "UDP Server successfully on" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    else
      echo "UDP Server did not turn on due to something" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    fi
    
    sleep 2
    
    break
    
  else
  
    echo "No internet connection" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    
    sleep 5
  
  fi

done


while true
do

  if [ $o -eq 5 ];
  then
    echo "Could not ping VPN Server 5 times in a row" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    echo "Rebooting" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    sleep 2
    sudo reboot
  fi

  ping 192.168.1.111 -c1 -W0.2 

  if [ $? -eq 0 ]; 
  then 
  
    if [ $o -gt 0 ];
    then
      echo "Reconnected!" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    fi

    count=$((count+1))
    i=0
    o=0    
    sleep 4
  else 
    echo $count "Successfull pings in a row before an unsuccessfull one" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    count=0
    i=$((i+1))
    sleep 2
  fi 

  if [ $i -eq 3 ]; 
  then 
    o=$((o+1))
    echo "On/Off in a row count = " $o >> log_WiFi_"$(date +"%d-%m-%y")".txt
    sleep 1
    
    sudo ifconfig wlan0 down
    
    if [ $? -eq 0 ];
    then
      echo "Adapter successfully off" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    else
      echo "Adapter did not turn off when it should" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    fi
      
    screen -S udp -X quit
    
    if [ $? -eq 0 ];
    then
      echo "screen called udp successfully quited(killed)" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    else
      echo "screen did not quit(get killed) as it should" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    fi
    
    sleep 5

    sudo ifconfig wlan0 up
    
    if [ $? -eq 0 ];
    then
      echo "Adapter successfully turned back on" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    else
      echo "Adapter did not turn back on as it should" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    fi
    
    screen -dm -S udp python3 /home/pi/udpServer.py
    
    if [ $? -eq 0 ];
    then
      echo "UDP screen successfully back on" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    else
      echo "UDP screen did not turn back on" >> log_WiFi_"$(date +"%d-%m-%y")".txt 
    fi
    
    i=0
    echo "Waiting 10sec to give the pi time to connect to network" >> log_WiFi_"$(date +"%d-%m-%y")".txt
    sleep 10
  fi 
done
