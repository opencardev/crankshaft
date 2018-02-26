Crankshaft = Raspberry Pi 💖 Android Auto
==

Crankshaft is a turn-key distribution for the Raspberry Pi. It transforms your Raspberry Pi to an [Android Auto headunit](https://www.android.com/auto/) thanks to the power of [OpenAuto](https://github.com/f1xpl/openauto) and [aasdk](https://github.com/f1xpl/aasdk).

This is the source code repository, just in case you want to build the system yourself. To get the binary without dealing with all this stuff, please head to [GetCrankshaft.com](http://getcrankshaft.com). There you can find guides and videos too. 

Does it work for you?
--

If you have a chance to try it, please report back at [ticket #2](https://github.com/htruong/crankshaft/issues/2).

Want to report a problem?
--

To file a bug or an enhancement idea, please file an issue on this repository. 

To help us help you, before reporting problems to this repository, I would appreciate if you could compile OpenAuto with X11 and run it the official way per [OpenAuto's instructions](https://github.com/f1xpl/openauto). To make the distribution easier and lightweight, I have opted to run OpenAuto under EGL instead of relying on X11. When you only observe the problem with Crankshaft and not with OpenAuto, should you file a bug request here.

For bugs or ideas related to OpenAuto or aasdk, please go to f1xpl's corresponding repository to file a bug report. If you file a bug request there, please make sure that you follow the instructions to compile it with X11 and not with EGL.

How to build a Crankshaft image
--

This repository provides a skeleton for you to build your own Crankshaft image, but it doesn't have all the binary blobs that are the result of the build process. When you supply all the three, you should be able to call `sudo ./make-crankshaft.sh` and it will build the `img` file for you.

There are three missing binary blobs in the `precompiled` directory: 

- `libQt5_OpenGLES2.tar.xz`: Qt5 library compiled with Raspberry Pi OpenGL ES2 library.
- `autoapp`: OpenAuto binary
- `libaasdk.so`: aasdk binary

Please head to the Wiki for instruction how to build each of the component yourself.


