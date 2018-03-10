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


**Version alpha0.1.7 2018-03-10**

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


**Version alpha0.1.6 2018-03-05**

What's new:

- Dev mode: Bridge GPIO4 to ground to enable dev mode
- Less services enabled means faster startup and less power consumption\
  Removed SSH, networking, dhcpd services by default.
- Misc. organizational changes

Release notes:

- Crankshaft is using a fork of OpenAuto with some experimental changes\
  http://github.com/htruong/openauto


Want to report a problem?
--

To file a bug or an enhancement idea, please file an issue on this repository. 

To help us help you, before reporting problems to this repository, I would appreciate if you could try [running Crankshaft under X11 under dev mode](https://github.com/htruong/crankshaft/wiki/Crankshaft-dev-mode). This will help in cases you use non standard hardware, for example, a custom HDMI screen. To make the distribution easier and lightweight, by default I opted to run OpenAuto under EGL instead of relying on X11, and this might cause OpenAuto to behave in ways that OpenAuto's author rather not deal with :)

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


