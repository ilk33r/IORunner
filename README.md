# IORunner

|| **Build** |
|---|---|
|**macOS Xcode 7.3**       |[![Build Status](https://travis-ci.org/ilk33r/IORunner.svg?branch=xcode_7.3)](https://travis-ci.org/ilk33r/IORunner)|
|**macOS Xcode 8**         |[![Build Status](https://travis-ci.org/ilk33r/IORunner.svg?branch=xcode_8)](https://travis-ci.org/ilk33r/IORunner)|
|**Ubuntu 14.04**          |[![Build Status](https://travis-ci.org/ilk33r/IORunner.svg?branch=trusty)](https://travis-ci.org/ilk33r/IORunner)|
|**Ubuntu 15.10**          |[![Build Status](https://travis-ci.org/ilk33r/IORunner.svg?branch=wily)](https://travis-ci.org/ilk33r/IORunner)|

IORunner is an application running on background. Application load installed extensions and calling every 0.3 seconds.
All extensions have these methods.

* __forStart() -> Void__ calling with when application start.
* --
* __inLoop() -> Void__ calling every 0.3 seconds.
* --
* __forStop() -> Void__ calling with when application stop.
* --		
* __forAsyncTask() -> Void__ calling from extension. This method working asynchronous.

### Release Notes:

#### V1.0.1

* Building with swift Preview 6
* Fixed ini parser when use = character in string.
* Added update feature to the installer.
* New extension! Controls bash scripts extension.
* Fixed GUI bug on Centos.
* Fixed shared library search paths on Centos.
