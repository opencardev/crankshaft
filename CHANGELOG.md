Version alpha0.1.0 2018-02-24
--

- Initial release.

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

