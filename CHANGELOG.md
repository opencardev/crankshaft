Version alpha0.1.5 2018-03-02
--

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

Version alpha0.1.1 2018-02-28
--

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

Version alpha0.1.0 2018-02-24
--

- Initial release


