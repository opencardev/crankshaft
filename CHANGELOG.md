#### Version alpha0.2.4 2018-05-18

What's new:

- Syncs with latest OpenAuto and AASDK.
- Buttons now look a bit nicer.
- Featured default wallpaper: Eve's "Camping (with Dock)"!
- Dev mode does not shut down crankshaft on ntp sync anymore.

What's new for developers:

- Now you can build your own Crankshaft system on raspbian \
  Use the scripts in `rpi_buildsystem`.
- The crankshaft buildscript is improved.
- Wifi client is supported in dev mode.
- Watchdog module is fixed & really enabled.
- Dev mode will have ntp enabled.

Known issues:

- If Android Auto doesn't automatically launch, disable Android debug.
- X11 still does not show cursors on projection mode, so no mouse.

#### Version alpha0.2.3 2018-04-18

What's new:

- Now you can configure many of the settings normally you have to use hardware jumpers\
  through software settings. Open the file `/boot/crankshaft/crankshaft_env.sh` to edit.
- Startup scripts via `/boot/crankshaft`. You can use both bash and python.
- Triggerhappy actions are exposed now via `boot/crankshaft/triggerhappy.conf`
- Fix "Crankshaft shuts down immediately after NTP time sync" when you set \
  `NO_CONNECTION_POWEROFF_MINS` on `crankshaft_env.sh` to 0. Fix #77.
- Some minor bug fixes: 
  Now crankshaft should mount `boot` and `root` ro correctly.\
  Video FPS is 30 by default for now (less janky animations).

What's new for developers:

- Clearer image building instructions.

Known issues:

- If Android Auto doesn't automatically launch, disable Android debug.
- X11 still does not show cursors on projection mode, so no mouse.

#### Version alpha0.2.2 2018-04-07

What's new:

- Image is 50M+ smaller. Less download, less bandwidth wasted!
- Everything you need to backup when you install crankshaft is at `boot/crankshaft`.
- The wallpaper location change to `boot/crankshaft` from `boot`.
- GPIO2KBD, virtual keyboard daemon from GPIO by Adafruit, \
  The config file is at `boot/crankshaft/gpio2kbd.cfg`.
- You can change the volume by connecting GND to GPIO 12/13 (or any GPIO). \
  (Issue #49, #33)
- Brightness change by GPIO - uncomment the GPIO2KBD config file.
- Trigger "OK Google" by GPIO - uncomment the GPIO2KBD config file.
- More GPU memshare by default. (Hopefully fix Issue #37)
- Fix OMXlayer hack for OpenAuto.

What's new for developers:

- The `rootfs` structure is much better organized. \
  Now what you see on `crankshaft/rootfs` is exactly what will be installed.
- The `dumb_suid` (poor man's sudo) is now less dangerous, still dumb.

Known issues:

- Error #2 on some phones still?
- X11 still does not show cursors on projection mode, so no mouse.


#### Version alpha0.2.1 2018-04-01

What's new:

- Raspbian base image upgraded from 2017-11 to 2018-03.
- Now all Pis of all generations should be supported.
- Brightness control on the main interface. (Issue #44, #49, #52)
- Pi now displays less verbose information. (Issue #35) \
  Thanks @byransays for the pull request.
- OpenAuto now detects already connected phones. (Issue #55) 
- The "display cursor" button is now hidden on touchscreen-capable devices.
- Tslib for more touchscreens support.
- The "sleep" button is unavailable - Pi now automatically sleeps after 30 secs.
- Pi now automatically shut down after 3 hours of idling.
- RtAudio option for future wireless support.

What's new for developers:

- Dev tool: New script to compile the Qt5 binary blob on Raspbian.

Known issues:

- Error #2 on some phones still?
- X11 still does not show cursors on projection mode, so no mouse.


#### Version alpha0.2.0 2018-03-13

What's new:

- Use your native audio output aka. Bluetooth stereo natively!\
  See https://github.com/f1xpl/openauto/pull/38 \
  See https://github.com/htruong/crankshaft/wiki/Using-your-Bluetooth-stereo \
  (Issue #9, #12)
- Audio no longer janks when phone's native audio is used.
- Audio and video no longer janks on native path either. (Issue #16, #25)
- Audio no longer crackle (too loud).
- The power LED is now disabled, it should save you several milliamps. \
  (Issue #31)

Known issues:

- Sometimes the Android Auto interface doesn't show up, just restart the Pi.
- Error #2 on some phones still?
- X11 still does not show cursors on projection mode, so no mouse.


#### Version alpha0.1.7 2018-03-10

What's new:

- Customize your Crankshaft install: Put `wallpaper.png` on `boot`.
- The "plug phone in" screen doesn't scream "I AM ERROR." (Issue #23) 
- Audio volume output is now louder. (Issue #24)
- You can switch to X11 mode without getting to dev mode.
- Switching to dev mode repeatedly doesn't generate different \
  SSH certificates (so no more warnings).
- OpenAuto now remembers your settings. (Issue #13)

Release notes:

- Turn down your stereo volume. Now Crankshaft is loud.
- To enable X11 mode, put a jumper on GPIO26-Ground.
- Somehow the cursor is still not showing up in X11 \
  So now you're still unable to use a mouse.


#### Version alpha0.1.6 2018-03-05

What's new:

- Dev mode: Bridge GPIO4 to ground to enable dev mode
- Less services enabled means faster startup and less power consumption\
  Removed SSH, networking, dhcpd services by default.
- Misc. organizational changes for scripts


#### Version alpha0.1.5 2018-03-02

What's new:

- Audio has very minimal stuttering: Pulseaudio problem solved
- Crankshaft is now overall much more polished experience
- The "plug phone in" interface has been revamped
- You can turn off the system with the power button
- Park mode (The "car sleep" icon) - Connect phone to wake it up
- Smaller binaries
- Splash screens/no more "rainbow" screen

Release notes:

- Qt5 has been rebuilt with many enhancements
- You can use mouse and keyboard (almost...)
- More information on debugging with X11/Wayland to come later


#### Version alpha0.1.1 2018-02-28

What's new:

- Raspbian Lite no longer resizes the FS on first time startup
- Faster startup time
- File system is now mounted read only -> Better SD card longevity
- Hopefully less cracks on audio output
- Allows `wpa_supplicant.conf` to be put in `precompiled`
- Allows screen flipping when putting a jumper on GPIO21/Ground
      (Pin 39-40 - that's the last row of pins)

Release notes:

- To mount system read/wite, put a jumper on GPIO4/Ground (Pin 07-09)
- Pulseaudio produces choppier audio even compared to previous one when two streams are played at the same time


#### Version alpha0.1.0 2018-02-24

- Initial release


