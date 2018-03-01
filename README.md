Crankshaft = Raspberry Pi 💖 Android Auto
==

Crankshaft is a turn-key free (as in freedom) distribution for the Raspberry Pi. It transforms your Raspberry Pi to an [Android Auto headunit](https://www.android.com/auto/). Android then displays your apps on the big, gorgeous 7 inches screen of the RPi and gives you a car-optimized interface and experience so you can drive distraction-free. No more fumbling with the phone's small screen!

Crankshaft is possible thanks to the power of [OpenAuto](https://github.com/f1xpl/openauto) and [aasdk](https://github.com/f1xpl/aasdk).

This is the source code repository, just in case you want to build the system yourself. To get the binary without dealing with all this stuff, please head to [GetCrankshaft.com](http://getcrankshaft.com). There you can find guides and videos too. 

Known problems
--

For some reason, several phone models complain about "incompatible device" when connecting to Crankshaft. Please be patient if Crankshaft does not work out-of-the-box yet for you. I am trying to figure out why so. If you have a device that you can lend me to debug, please email.

It seems you'll have a better chance of getting it to work using the official screen. If you don't have the official screen or touchscreen, you should get one - it is a cheap and very good screen. If you insist on using a custom screen, compile OpenAuto with X11 per [OpenAuto's instructions](https://github.com/f1xpl/openauto/wiki/Build-instructions).

Does it work for you?
--

If you have a chance to try it, please spend a minute to report back whether it works or not at [Hardware Compatibility List](https://github.com/htruong/crankshaft/issues/2).

If you have pictures of your project, feel free to [add to the collection](https://photos.app.goo.gl/81hQ6wTuLFNGmRHh2).

Release Highlights
--

[Full Changelog](https://github.com/htruong/crankshaft/blob/master/CHANGELOG.md)

**Version alpha0.1.1 2018-02-28**

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
- Pulseaudio produced choppier audio even compared to previous one when two streams are played at the same time.

Want to report a problem?
--

To file a bug or an enhancement idea, please file an issue on this repository. 

To help us help you, before reporting problems to this repository, I would appreciate if you could compile OpenAuto with X11 and run it the official way per [OpenAuto's instructions](https://github.com/f1xpl/openauto/wiki/Build-instructions). To make the distribution easier and lightweight, I have opted to run OpenAuto under EGL instead of relying on X11. When you only observe the problem with Crankshaft and not with OpenAuto, should you file a bug request here. You do not have to, if you don't know how -- but expect a longer time for us to resolve it.

For bugs or ideas related to OpenAuto or aasdk, please go to f1xpl's corresponding repository to file a bug report. If you file a bug request there, please make sure that you follow the instructions to compile it with X11 and not with EGL.

How to build a Crankshaft image
--

This repository provides a skeleton for you to build your own Crankshaft image, but it doesn't have all the binary blobs that are the result of the build process. When you supply all the three, you should be able to call `sudo ./make-crankshaft.sh` and it will build the `img` file for you.

There are three missing binary blobs in the `precompiled` directory: 

- `libQt5_OpenGLES2.tar.xz`: Qt5 library compiled with Raspberry Pi OpenGL ES2 library. It is the archive of `/usr/local/qt5`
- `autoapp`: OpenAuto binary
- `libaasdk.so`: aasdk binary

Please head to the Wiki for instruction [how to build each of the components yourself](https://github.com/htruong/crankshaft/wiki/Building-the-binary-blobs). The scripts provided in this repository allows you to [cross-compile them](https://github.com/htruong/crankshaft/wiki/Cross-compile-on-your-computer).


