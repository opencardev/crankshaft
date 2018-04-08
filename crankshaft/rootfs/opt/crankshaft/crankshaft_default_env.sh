DEV_PIN=4

# These two pins will be depreciated soon in beta
# You can configure crankshaft with settings in this file
INVERT_PIN=21
X11_PIN=26

# screen brightness related stuff
BRIGHTNESS_FILE=/sys/class/backlight/rpi_backlight/brightness
BR_MIN=30
BR_MAX=255
BR_STEP=25

# power mgmt related stuff
NO_CONNECTION_POWEROFF_MINS=15
DISCONNECTION_POWEROFF_MINS=120
DISCONNECTION_SCREEN_POWEROFF_SECS=30

# Flip the screen
FLIP_SCREEN=0

# Start OpenAuto in X11 or EGL
# By default, EGL, but if you can't get it to work, do X11
START_X11=0