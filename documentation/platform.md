# Platform

Platform is a class implementing [IPlatform](../src/res/platforms/IPlatform.hx) interface that provide necessery systems to handle platform-specific implementaions of things like frame buffer output, sounds, inputs, etc.

## Creating a Platform

`RES.boot()` function requires an object implementing the `IPlatform` interface.

1. Implement `IPlatform`
2. Implement `IAudioMixer` interface or `AudioMixerBase` class
3. Implement `IAudioBuffer`
4. Implement `IAudioChannel`
5. Subclass `res.display.FrameBuffer`