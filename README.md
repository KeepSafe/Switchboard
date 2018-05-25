Switchboard - easy A/B testing for your mobile app
===

## What it does
Switchboard is a simple way to remote control your mobile application even after you've shipped it to your users'
devices.

Use Switchboard to
* Stage-rollout new features to users
* A/B-test user flows, messaging, colors, features, etc.
* Add a feature flag to anything you want to remotely enable/disable

Switchboard lets you control what happens in your app. Quick, easy, useful.

Additionally, Switchboard segments your users consistently; because user segmentation is based upon a UUID that is computed once, the experience you switch on and off using Switchboard is consistent across sessions.

## What it does not do (i.e. what you have to do yourself)

Switchboard does not give you analytics, nor does it automatically administer and optimize your A/B tests. It also doesn't give you nice graphs and stuff. You can get all of that by plugging an analytics package into your app which you're probably doing anyway.

## Features

* Highly scalable and incredibly lightweight
* Consistent user segmentation based off a computed UUID
* Define experiments for specific application versions, OS version, language settings and more
* Comes with built-in configurations for production and staging environment
* Preserves state when device is offline; configurations are cached on clients across sessions
* Flexible custom parameters for experiments

## What Switchboard was designed for

Switchboard was designed as a super lightweight and flexible mobile A/B testing framework. 

### Infrastructure

The goal was to serve millions of requests very reliablly without much infrastructure. It should easily scale horizontally to avoid overhead in maintaining it while your application scales. It is designed without a database or any other type of persistent storage that would slow it down.

### User segmentation
Consistency in user segmentation is one of the most important things in A/B testing. This means that one individual user will always have a consistent experience over a long period of time. 

Switchboard does consistent user segmentation based on a unique device id.

## How to use it

### iOS

Debug interface and extensive documentation here: [Switchboard-iOS](https://github.com/KeepSafe/Switchboard-iOS)

### Server

[Coming soon...]

### Android

[Coming soon...]

## More information about it:

* [Keepsafe Engineering Blog](https://medium.com/keepsafe-engineering/a-b-testing-for-mobile-apps-made-easy-348b68e68362#.j7f2x848n)
* [Quora](http://www.quora.com/A-B-Testing/How-do-companies-practically-A-B-Test-new-versions-of-native-mobile-apps-that-are-already-in-production)

## Problems & Bugs

Please report issues on each of the server or mobile repositories above.

## License
Switchboard is licensed under the [Apache Software License, 2.0 ("Apache 2.0")](http://www.apache.org/licenses/LICENSE-2.0)

## Authors

Switchboard is brought to you by [Philipp Berner](https://github.com/philippb) and [Zouhair Belkoura](https://github.com/zouhairb), founders of Keepsafe, and the rest of the [Keepsafe team](https://www.getkeepsafe.com/about.html). 

We'd love to have you contribute or [join us](https://www.getkeepsafe.com/careers.html)!

## Used in production for many millions of users

* Keepsafe (www.getkeepsafe.com)
