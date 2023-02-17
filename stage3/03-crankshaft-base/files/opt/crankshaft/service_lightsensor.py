#!/usr/bin/python3 -u

import smbus
import os
import subprocess
from time import sleep
from python_tsl2591 import tsl2591


def get_var(varname):
    try:
        CMD = 'echo $(source /boot/crankshaft/crankshaft_env.sh; echo $%s)' % varname
        p = subprocess.Popen(CMD, stdout=subprocess.PIPE,
                             shell=True, executable='/bin/bash')
        return p.stdout.readlines()[0].strip()
    except:
        CMD = 'echo $(source /opt/crankshaft/crankshaft_default_env.sh; echo $%s)' % varname
        p = subprocess.Popen(CMD, stdout=subprocess.PIPE,
                             shell=True, executable='/bin/bash')
        return p.stdout.readlines()[0].strip()

# ---------------------------------
# Get Variables from Config
daynight_gpio = int(get_var('DAYNIGHT_PIN'))
LIGHTSENSOR = str(get_var('LIGHTSENSOR_TYPE').decode())
TSL_I2C_BUS = int(get_var('TSL_I2C_BUS'))
TSL_ADDR = int(get_var('TSL_ADDR').decode(),16)
# ---------------------------------


def get_LUX(LIGHTSENSOR):
    print(LIGHTSENSOR)
    if 'TSL2561' == LIGHTSENSOR:
        Lux = get_LUX_TSL2561(TSL_I2C_BUS, TSL_ADDR)
    elif 'TSL2591' == LIGHTSENSOR:
        Lux = get_LUX_TSL2591(TSL_I2C_BUS, TSL_ADDR)
    else:
        Lux = 0
    return round(Lux, 1)


def get_LUX_TSL2561(TSL_I2C_BUS, TSL_ADDR):
    i2cBus = smbus.SMBus(TSL_I2C_BUS)
    # Start messure with 402 ms
    # (scale factor 1)
    i2cBus.write_byte_data(TSL_ADDR, 0x80, 0x03)

    # read global brightness
    # read low byte
    LSB = i2cBus.read_byte_data(TSL_ADDR, 0x8C)
    # read high byte
    MSB = i2cBus.read_byte_data(TSL_ADDR, 0x8D)
    Ambient = (MSB << 8) + LSB
    # print ("Ambient: {}".format(Ambient))

    # read infra red
    # read low byte
    LSB = i2cBus.read_byte_data(TSL_ADDR, 0x8E)
    # read high byte
    MSB = i2cBus.read_byte_data(TSL_ADDR, 0x8F)
    Infrared = (MSB << 8) + LSB
    # print ("Infrared: {}".format(Infrared))

    # Calc visible spectrum
    Visible = Ambient - Infrared
    # print ("Visible: {}".format(Visible))

    # Calc factor Infrared/Ambient
    Ratio = 0
    Lux = 0
    if Ambient != 0:
        Ratio = float(Infrared)/float(Ambient)
        # print ("Ratio: {}".format(Ratio))

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
        return round(Lux, 1)


def get_LUX_TSL2591(TSL_I2C_BUS, TSL_ADDR):
    # Initialize the connector
    tsl = tsl2591(i2c_bus=TSL_I2C_BUS, sensor_address=TSL_ADDR)
    full, ir = tsl.get_full_luminosity()
    Lux = tsl.calculate_lux(full, ir)
    return round(Lux, 1)


lastvalue = 0

while True:
    Luxrounded = get_LUX(LIGHTSENSOR)
    if lastvalue != Luxrounded:
            # print ("Lux = {}\n".format(Luxrounded))
        os.system("echo {} > /tmp/tsl2561".format(Luxrounded))
        lastvalue = Luxrounded
        # Set display brightness
        if Luxrounded <= int(get_var('LUX_LEVEL_1')):
            os.system("crankshaft brightness set " +
                      str(int(get_var('DISP_BRIGHTNESS_1'))) + " &")
            step = 1
        elif Luxrounded > int(get_var('LUX_LEVEL_1')) and Luxrounded < int(get_var('LUX_LEVEL_2')):
            os.system("crankshaft brightness set " +
                      str(int(get_var('DISP_BRIGHTNESS_2'))) + " &")
            step = 2
        elif Luxrounded >= int(get_var('LUX_LEVEL_2')) and Luxrounded < int(get_var('LUX_LEVEL_3')):
            os.system("crankshaft brightness set " +
                      str(int(get_var('DISP_BRIGHTNESS_3'))) + " &")
            step = 3
        elif Luxrounded >= int(get_var('LUX_LEVEL_3')) and Luxrounded < int(get_var('LUX_LEVEL_4')):
            os.system("crankshaft brightness set " +
                      str(int(get_var('DISP_BRIGHTNESS_4'))) + " &")
            step = 4
        elif Luxrounded >= int(get_var('LUX_LEVEL_4')) and Luxrounded < int(get_var('LUX_LEVEL_5')):
            os.system("crankshaft brightness set " +
                      str(int(get_var('DISP_BRIGHTNESS_5'))) + " &")
            step = 5
        elif Luxrounded >= int(get_var('LUX_LEVEL_5')):
            os.system("crankshaft brightness set " +
                      str(int(get_var('DISP_BRIGHTNESS_5'))) + " &")
            step = 6

        if daynight_gpio == 0:
            if step <= int(get_var('TSL2561_DAYNIGHT_ON_STEP')):
                print("Lux = {} | ".format(Luxrounded) +
                      "Level " + str(step) + " -> trigger night")
                os.system("touch /tmp/night_mode_enabled >/dev/null 2>&1")
            else:
                if step > int(get_var('TSL2561_DAYNIGHT_ON_STEP')):
                    print("Lux = {} | ".format(Luxrounded) +
                          "Level " + str(step) + " -> trigger day")
                    os.system("sudo rm /tmp/night_mode_enabled >/dev/null 2>&1")

    sleep(int(get_var('TSL2561_CHECK_INTERVAL')))
