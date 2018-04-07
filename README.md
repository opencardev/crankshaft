Crankshaft = Raspberry Pi 💖 Android Auto
==

Crankshaft is a turn-key free (as in freedom) distribution for the Raspberry Pi. It transforms your Raspberry Pi to an [Android Auto headunit](https://www.android.com/auto/).

This is the source code repository, just in case you want to build the system yourself. To get the binary without dealing with all this stuff, please head to [GetCrankshaft.com](http://getcrankshaft.com). Crankshaft is possible thanks to the power of [OpenAuto](https://github.com/f1xpl/openauto) and [aasdk](https://github.com/f1xpl/aasdk). Crankshaft and OpenAuto are in no way related or certfied by either Google or Android.

Getting Started
--

It's easy to get started even when you're new to Raspberry Pi and know nothing about electronics. [Check here for the latest guide](https://github.com/htruong/crankshaft/wiki/Getting-started-with-Crankshaft). 


Where to get help
--

The premier place to discuss your question or idea is [the subreddit (BETA)](https://www.reddit.com/r/crankshaft/). 

Several other questions such as "Does OK Google work? Can I use a custom screen?" get asked a lot and might have already been answered in the [tips and tricks](https://github.com/htruong/crankshaft/wiki/Hidden-tips,-tricks,-settings,-etc.) page. If you have questions, [check out the growing FAQs](https://github.com/htruong/crankshaft/wiki/Frequently-Asked-Questions).

If you have pictures of your project, feel free to [add to the collection](https://photos.app.goo.gl/81hQ6wTuLFNGmRHh2).


Will it/Does it work for you?
--

If you don't have the official touch screen and just want to see whether Crankshaft will work with the phone you have before spending money to buy the screen, try [this trick](https://github.com/htruong/crankshaft/wiki/Frequently-Asked-Questions#i-have-a-pi3-how-can-i-test-crankshaft-compatibility-with-my-phone-before-i-spend-the-money-to-buy-the-official-screen).

If you want to know for sure or have a chance to try it, please spend a minute to report back whether it works or not at [Hardware Compatibility List](https://github.com/htruong/crankshaft/issues/2). If Crankshaft doesn't work but you're capable of compiling software on Linux, there is a chance chance you can get it to work [following OpenAuto's simple intructions](https://github.com/htruong/crankshaft/issues/2).


Release Highlights
--

[Full Changelog](https://github.com/htruong/crankshaft/blob/master/CHANGELOG.md)

##### Version alpha0.2.2 2018-04-07

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

##### Version alpha0.2.1 2018-04-01

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


##### Version alpha0.2.0 2018-03-13

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



Want to report a problem?
--

To file a bug or an enhancement idea, please file an issue on this repository. 

To help us help you, before reporting problems to this repository, I would appreciate if you could try [running Crankshaft under X11](https://github.com/htruong/crankshaft/wiki/Crankshaft-dev-mode). This will help in cases you use non standard hardware, for example, a custom HDMI screen. To make the distribution easier and lightweight, by default I opted to run OpenAuto under EGL instead of relying on X11, and this might cause OpenAuto to behave in ways that OpenAuto's author rather not deal with :)

Known problems
--

For some reason, several phone models complain about "incompatible device" when connecting to Crankshaft. Please be patient if Crankshaft does not work out-of-the-box yet for you. I am trying to figure out why so. If you have a device that you can lend me to debug, please email.

It seems you'll have a better chance of getting it to work using the official screen. If you don't have the official screen or touchscreen, you should get one - it is a cheap and very good screen. If you insist on using a custom screen and the custom screen does not work out of the box, [try running Crankshaft under X11 under dev mode](https://github.com/htruong/crankshaft/wiki/Crankshaft-dev-mode).

Other projects
--

OpenAuto and Crankshaft are not the only people in this world experimenting with this idea. 

Some other developers worked hard on this too, and you might want to give them a try. [Here is another solution that works on the Pi](https://github.com/viktorgino/headunit-desktop), [here is one that works on an Android tablet](https://github.com/borconi/headunit).


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


