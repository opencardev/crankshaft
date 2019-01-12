#!/usr/bin/python3 -u

import smbus
import os
import subprocess
from time import sleep

def get_var(varname):
    try:
        CMD = 'echo $(source /boot/crankshaft/crankshaft_env.sh; echo $%s)' % varname
        p = subprocess.Popen(CMD, stdout=subprocess.PIPE, shell=True, executable='/bin/bash')
        return int(p.stdout.readlines()[0].strip())
    except:
        CMD = 'echo $(source /opt/crankshaft/crankshaft_default_env.sh; echo $%s)' % varname
        p = subprocess.Popen(CMD, stdout=subprocess.PIPE, shell=True, executable='/bin/bash')
        return int(p.stdout.readlines()[0].strip())

# ---------------------------------
# the addresss of TSL2561 can be
# 0x29, 0x39 or 0x49
BUS = 1
TSL2561_ADDR = 0x39

daynight_gpio = get_var('DAYNIGHT_PIN')
# ---------------------------------

i2cBus = smbus.SMBus(BUS)

# Start messure with 402 ms
# (scale factor 1)
i2cBus.write_byte_data(TSL2561_ADDR, 0x80, 0x03)

lastvalue = 0

while True:
  # read global brightness
  # read low byte
  LSB = i2cBus.read_byte_data(TSL2561_ADDR, 0x8C)
  # read high byte
  MSB = i2cBus.read_byte_data(TSL2561_ADDR, 0x8D)
  Ambient = (MSB << 8) + LSB
  #print ("Ambient: {}".format(Ambient))

  # read infra red
  # read low byte
  LSB = i2cBus.read_byte_data(TSL2561_ADDR, 0x8E)
  # read high byte
  MSB = i2cBus.read_byte_data(TSL2561_ADDR, 0x8F)
  Infrared = (MSB << 8) + LSB
  #print ("Infrared: {}".format(Infrared))

  # Calc visible spectrum
  Visible = Ambient - Infrared
  #print ("Visible: {}".format(Visible))

  # Calc factor Infrared/Ambient
  Ratio = 0
  Lux = 0
  if Ambient != 0:
    Ratio = float(Infrared)/float(Ambient)
    #print ("Ratio: {}".format(Ratio))

    # Calc lux based on data sheet TSL2561T
    # T, FN, and CL Package
    if 0 < Ratio <= 0.50:
      Lux = 0.0304*float(Ambient) - 0.062*float(Ambient)*(Ratio**1.4)
    elif 0.50 < Ratio <= 0.61:
      Lux = 0.0224*float(Ambient) - 0.031*float(Infrared)
    elif 0.61 < Ratio <= 0.80:
      Lux = 0.0128*float(Ambient) - 0.0153*float(Infrared)
    elif 0.80 < Ratio <= 1.3:
      Lux = 0.00146*float(Ambient) - 0.00112*float(Infrared)
    else:
      Lux = 0
    Luxrounded=round(Lux,1)
    if lastvalue != Luxrounded:
        #print ("Lux = {}\n".format(Luxrounded))
        os.system("echo {} > /tmp/tsl2561".format(Luxrounded))
        lastvalue = Luxrounded
        #Set display brigthness
        if Luxrounded <= get_var('LUX_LEVEL_1'):
            os.system("crankshaft brightness set " + str(get_var('DISP_BRIGHTNESS_1')) + " &")
            step = 1
        elif Luxrounded > get_var('LUX_LEVEL_1') and Luxrounded < get_var('LUX_LEVEL_2'):
            os.system("crankshaft brightness set " + str(get_var('DISP_BRIGHTNESS_2')) + " &")
            step = 2
        elif Luxrounded >= get_var('LUX_LEVEL_2') and Luxrounded < get_var('LUX_LEVEL_3'):
            os.system("crankshaft brightness set " + str(get_var('DISP_BRIGHTNESS_3')) + " &")
            step = 3
        elif Luxrounded >= get_var('LUX_LEVEL_3') and Luxrounded < get_var('LUX_LEVEL_4'):
            os.system("crankshaft brightness set " + str(get_var('DISP_BRIGHTNESS_4')) + " &")
            step = 4
        elif Luxrounded >= get_var('LUX_LEVEL_5'):
            os.system("crankshaft brightness set " + str(get_var('DISP_BRIGHTNESS_5')) + " &")
            step = 5

        if daynight_gpio == 0:
            if step <= get_var('TSL2561_DAYNIGHT_ON_STEP'):
                print("Lux = {} | ".format(Luxrounded) + "Level " + str(step) + " -> trigger night")
                os.system("touch /tmp/night_mode_enabled >/dev/null 2>&1")
            else:
                if  step > get_var('TSL2561_DAYNIGHT_ON_STEP'):
                    print("Lux = {} | ".format(Luxrounded) + "Level " + str(step) + " -> trigger day")
                    os.system("sudo rm /tmp/night_mode_enabled >/dev/null 2>&1")
  sleep (get_var('TSL2561_CHECK_INTERVAL'))
