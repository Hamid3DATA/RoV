#!/usr/bin/env python3

# https://raw.githubusercontent.com/Footleg/pygame-controller/master/examples/SentinelBoard/SimpleTwinMotor.py
# https://stackoverflow.com/questions/18743962/python-send-udp-packet



""" Example of a robot using tank steering with two motors for left and right tracks.
    This robot uses the Sentinel board from Footleg Robotics. The speed and steering are
    controlled from the left and right sticks respectively, so in this example the
    change handler functions store the stick postions in variables and these are
    used to update the motor powers in the main program loop. (See the PiconZero
    Simple Twin Motor example for an alternative way to control a robot with just a
    single stick for both power and steering).
"""
import pygame, random, time, math
from pygamecontroller import RobotController
#import sentinelboard

import socket

UDP_IP = "127.0.0.1"
UDP_IP = "10.208.123.2"

UDP_PORT = 5005
MESSAGE = "Hello, World!"

print("UDP target IP:", UDP_IP)
print("UDP target port:", UDP_PORT)
print("message:", MESSAGE)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP






#Initialise global variables

right = 0
left = 0
power = 0
turn = 0
minMovingSpeed = 30
message = ""

#Multiplier applied to speed so top speed is set when stick is not quite at maximum position
speedFactor = 1.0

#sb = sentinelboard.SentinelBoard()



def initStatus(status):
    """Callback function which displays status during initialisation"""
    if status == 0 :
        print("Supported controller connected")
    elif status < 0 :
        print("No supported controller detected")
    else:
        print("Waiting for controller {}".format( status ) )


def leftStickChangeHandler(valLR, valUD):
    """Handler function for left analogue stick"""
    global left
    left = valUD


def rightStickChangeHandler(valLR, valUD):
    """Handler function for right analogue stick"""
    global right
    right = valUD


def main():
    global message
    ## Check that required hardware is connected ##

    #Initialise the controller board


    #Run in try..finally structure so that program exits gracefully on hitting any
    #errors in the callback functions
    try:
        cnt = RobotController("Turbo 4WD Robot", initStatus,
                              leftStickChanged = leftStickChangeHandler,
                              rightStickChanged = rightStickChangeHandler)

        if cnt.initialised :
            keepRunning = True
            #Indicate success here, we are ready to run
            print (' yippee!!!!!')
        else:
            keepRunning = False

        # -------- Main Program Loop -----------
        while keepRunning == True :
            cnt.message = message


            # Trigger stick events and check for quit
            keepRunning = cnt.controllerStatus()
    
            message=("%s,%s,s\n" % (str(int(right * 255)), str(int(left * 255))))
            #message=("o %s %s\r" % (str(int(right * 255)), str(int(left * 255))))

            print(message)
            sock.sendto(bytes(message, "utf-8"), (UDP_IP, UDP_PORT))
            #motorSpeed(power, turn)
    finally:
        #Clean up and turn off Blinkt LEDs
        #sb.allOff()
        pygame.quit()


if __name__ == '__main__':
    main()
