#!/usr/bin/python3

import sys
import socket

extcommand = str.strip(sys.argv[1])

UDP_IP = "127.0.0.1"
UDP_PORT = 6000

def PiCam_SendCommand(command):
    # Create a TCP/IP socket with check
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.sendto(command.encode(), (UDP_IP, UDP_PORT))
        time.sleep(0.1)
        sock.close()

    except:
        quit()

if extcommand == "Background":
    PiCam_SendCommand("Background")

if extcommand == "Foreground":
    PiCam_SendCommand("Foreground")

if extcommand == "Stop":
    PiCam_SendCommand("Stop")

if extcommand == "Save":
    PiCam_SendCommand("SaveEvent")

if extcommand == "Record":
    PiCam_SendCommand("RearcamMode,false")
    PiCam_SendCommand("Record")

if extcommand == "PosYUp":
    PiCam_SendCommand("PosYUp")

if extcommand == "PosYDown":
    PiCam_SendCommand("PosYDown")

if extcommand == "ZoomPlus":
    PiCam_SendCommand("ZoomPlus")

if extcommand == "ZoomMinus":
    PiCam_SendCommand("ZoomMinus")

if extcommand == "Rearcam":
    PiCam_SendCommand("Background")
    PiCam_SendCommand("Stop")
    PiCam_SendCommand("RearcamMode,true")
    PiCam_SendCommand("RearcamOverlay,true")
    PiCam_SendCommand("Foreground")

if extcommand == "DashcamMode":
    PiCam_SendCommand("RearcamMode,false")
    PiCam_SendCommand("Background")

if extcommand == "Dashcam":
    PiCam_SendCommand("Background")
    PiCam_SendCommand("RearcamMode,false")
    PiCam_SendCommand("Foreground")

if extcommand == "Init":
    PiCam_SendCommand("Foreground")
    PiCam_SendCommand("RearcamMode,false")
    PiCam_SendCommand("Zoom,1")
    PiCam_SendCommand("RecordMode,true,0")
    PiCam_SendCommand("AWB,auto")
    PiCam_SendCommand("EXP,auto")
    PiCam_SendCommand("Background")
