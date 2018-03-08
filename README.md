Crankshaft = Raspberry Pi 💖 Android Auto
==

Crankshaft is a turn-key free (as in freedom) distribution for the Raspberry Pi. It transforms your Raspberry Pi to an [Android Auto headunit](https://www.android.com/auto/).

This is the source code repository, just in case you want to build the system yourself. To get the binary without dealing with all this stuff, please head to [GetCrankshaft.com](http://getcrankshaft.com). Crankshaft is possible thanks to the power of [OpenAuto](https://github.com/f1xpl/openauto) and [aasdk](https://github.com/f1xpl/aasdk). Crankshaft and OpenAuto are in no way related or certfied by either Google or Android.


Have questions? We have answers!
--

The premier place to discuss your question or idea is [the subreddit (BETA)](https://www.reddit.com/r/crankshaft/). 

Several other questions such as "Does OK Google work? Can I use a custom screen?" get asked a lot and might have already been answered in the [tips and tricks](https://github.com/htruong/crankshaft/wiki/Hidden-tips,-tricks,-settings,-etc.) page. If you have questions, [check out the growing FAQs](https://github.com/htruong/crankshaft/wiki/Frequently-Asked-Questions).


Will it/Does it work for you?
--

If you don't have the official touch screen and just want to see whether Crankshaft will work with the phone you have before spending money to buy the screen, try [this trick](https://github.com/htruong/crankshaft/wiki/Frequently-Asked-Questions#i-have-a-pi3-how-can-i-test-crankshaft-compatibility-with-my-phone-before-i-spend-the-money-to-buy-the-official-screen).

If you want to know for sure or have a chance to try it, please spend a minute to report back whether it works or not at [Hardware Compatibility List](https://github.com/htruong/crankshaft/issues/2). Crankshaft did some tweaks to the way standard OpenAuto works, so that might have caused some incompatibility among phones. If Crankshaft doesn't work but you're capable of compiling software on Linux, there is some chance you can get it to work [following OpenAuto's simple intructions](https://github.com/htruong/crankshaft/issues/2).

If you have pictures of your project, feel free to [add to the collection](https://photos.app.goo.gl/81hQ6wTuLFNGmRHh2).

Release Highlights
--

[Full Changelog](https://github.com/htruong/crankshaft/blob/master/CHANGELOG.md)

**Version alpha0.1.6 2018-03-05**

What's new:

- Dev mode: Bridge GPIO4 to ground to enable dev mode
- Less services enabled means faster startup and less power consumption\
  Removed SSH, networking, dhcpd services by default.
- Misc. organizational changes

Release notes:

- Crankshaft is using a fork of OpenAuto with some experimental changes\
  http://github.com/htruong/openauto

**Version alpha0.1.5 2018-03-02**

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


Want to report a problem?
--

To file a bug or an enhancement idea, please file an issue on this repository. 

To help us help you, before reporting problems to this repository, I would appreciate if you could try [running Crankshaft under X11 under dev mode](https://github.com/htruong/crankshaft/wiki/Crankshaft-dev-mode). This will help in cases you use non standard hardware, for example, a custom HDMI screen. To make the distribution easier and lightweight, by default I opted to run OpenAuto under EGL instead of relying on X11, and this might cause OpenAuto to behave in ways that OpenAuto's author rather not deal with :)

Known problems
--

For some reason, several phone models complain about "incompatible device" when connecting to Crankshaft. Please be patient if Crankshaft does not work out-of-the-box yet for you. I am trying to figure out why so. If you have a device that you can lend me to debug, please email.

It seems you'll have a better chance of getting it to work using the official screen. If you don't have the official screen or touchscreen, you should get one - it is a cheap and very good screen. If you insist on using a custom screen and the custom screen does not work out of the box, [try running Crankshaft under X11 under dev mode](https://github.com/htruong/crankshaft/wiki/Crankshaft-dev-mode).


How to build a Crankshaft image
--

This repository provides a skeleton for you to build your own Crankshaft image, but it doesn't have all the binary blobs that are the result of the build process. When you supply all the three, you should be able to call `sudo ./make-crankshaft.sh` and it will build the `img` file for you.

There are three missing binary blobs in the `precompiled` directory: 

- `libQt5_OpenGLES2.tar.xz`: Qt5 library compiled with Raspberry Pi OpenGL ES2 library. It is the archive of `/usr/local/qt5`
- `autoapp`: OpenAuto binary
- `libaasdk.so`: aasdk binary

There is currently one additional missing small script:

- `dumb_suid`: A way to exec bash scripts in `opt/crankshaft` as root. Compile it (in `src`) and put it to `precompiled/opt`. Bash scripts can't do `suid`.

Please head to the Wiki for instruction [how to build each of the components yourself](https://github.com/htruong/crankshaft/wiki/Building-the-binary-blobs). The scripts provided in this repository allows you to [cross-compile them](https://github.com/htruong/crankshaft/wiki/Cross-compile-on-your-computer).


