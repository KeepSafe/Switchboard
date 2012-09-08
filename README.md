Switchboard - easy A/B testing for your mobile app
===

## What it does
Switchboard is a simple way to remote control your mobile application even after you shipped it to your users'
devices.
Use switchboard to
* Stage-rollout new features to users
* A/B-test user flows, messaging, colors, features
* anything you want to remote-control

Switchboard lets you control what happens in your app. Quick, easy, useful.

*Switchboard segments your users consistently.* Because user segmentation is based only on UUID that is computed once, the experience you switch on and off using Switchboard is consistent across sessions.

## What it does not do (what you have to do yourself)
Switchboard does not give you analytics, nor does it automatic administration and optimization of your A/B tests. It also doesn't give you nice graphs and stuff. You can get all of that by plugging an analytics package into your app which you're probably doing anyway.

## Features
* Consistent user segmentation based on device ID
* Define experiments for specific application versions, OS version, language settings and more
* Comes with build in configuration for production and staging environment
* Highly scalable
* Safe when device is offline
* Flexible custom parameters for experiments

## What Switchboard was designed for
Switchboard was design as a super light weight and very flexible mobile A/B testing framework. 
### Infrastructure
The goal was to serve millions of requests very reliable without much infrastructure. It should easy scale horizontally to avoid overhead in
maintaining it while your application scales. It is designed without a database or any other type of persistent storage that would slow
it down.
### User segmentation
Consistency in user segmentation is one of the most important things in A/B testing. This means that one individual user will always have a consistent experience
 over time. Switchboard does consistent user segmentation based on a unique device id.

## How to use it
### Client
The Switchboard client lib is available for android and iOS. The following examples give you a brief overview on how to get started. You can find a more in depth 
documentation under the [Wiki](https://github.com/KeepSafe/Switchboard/wiki)

#### Android
Link the Switchboard project to your andorid project as a library project. You only need to initialize the Switchboard core at the application start once. 
Then, you can add switches to your app and have the Switchboard give you the current state.

You can customize the DynamicConfigManager to send all sorts of information to the Switchboard server for control decisions, e.g. location, OS version, device, language.

Here's some on/off switch example code on Android:

```java
  	Context myContext = this.getApplicationContext();
	String experimentName = "showSmiley";
	
	//get settings from Switchboard
	boolean isSmiling = Switchboard.isInExperiment(myContext, experimentName);

	//Switching code for testing
	if (isSmiling) //variant A
		showSmileyWelcomeMessage();
	else //variant B
		showFrownyFace();
```

And it works for varying any value too. Again, on Android:

```java
	if (isSmiling) {
		if(Switchboard.hasExperimentValues(myContext, experimentName)) {
			
			//get remote controlled values from Switchboard
			JSONObject smileValues = Switchboard.getExperimentValueFromJson(myContext, experimentName);

			int smileWidth = smileValues.getInt("width");

			//do something with it
			prepareSmiley(smileWidth);
			showSmileyWelcomeMessage();
		}
	}
```

#### iOS
Please look at the iOS sample implementation under [client/ios/SwitchboardSample](https://github.com/KeepSafe/Switchboard/tree/master/client/ios/SwitchboardSample)

### Server
The server receives a UUID that the client generated as well as many other parameters like app version, OS version, device language, location.
Users are divided into 100 consistent user buckets. Switchboard makes it incredible easy to write new tests based on the given parameters.

Example code of the PHP implementation for a simple on/off switch:

```php
	$manager = new SwitchboardManager($_GET);
	
	//put 50% of your users into the showSmiley A/B test
	$resultArray['showSmiley'] = $manager->turnOnBucket(0, 50);

	//return result array as JSON
	$manager->renderResultJson($resultArray);
```

You can do more complex things if you want:

```php
	$manager = new SwitchboardManager($_GET);
	$experiments = new SwitchboardExperiments($manager);
	
	//put a percentage of users in the test and vary smile width
	$resultArray['showSmiley'] = $experiments->smileyVariation($uuid, $lang);
	
	//return result array as JSON
    $manager->renderResultJson($resultArray);
	
	class SwitchboardExperiments {
		function smileyVariation($uuid, $lang){

			//turn it on for 50% only
			if ($this->$manager->isInBucket($uuid, 0, 50)){

				$values = array();
				//and then vary the values
				if ($this->$manager->$lang == "eng"){ //broad smiles in US
					$values['width'] = 10;
				} else if ($this->$manager->$lang == "deu"){ //more subtle in Germany
					$values['width'] = 9;
				} else {
					return $this->$manager->inactiveExperimentReturnArray();
				}
				return $this->$manager->activeExperimentReturnArray($values);
			}

			//default
			return $this->$manager->inactiveExperimentReturnArray();
		}
	}
```

## More information on how to use it
* [KeepSafe Engineering Blog](http://keepsafe-engineering.tumblr.com/post/28437940369/easy-mobile-ab-testing)
* [Quora](http://www.quora.com/A-B-Testing/What-is-the-best-way-to-do-A-B-testing-for-mobile-apps)

## Problems & Bugs
Please us the [Github Issue tracker](https://github.com/KeepSafe/Switchboard/issues) to commit bugs

## License
Switchboard is licensed under the [Apache Software License, 2.0 ("Apache 2.0")](http://www.apache.org/licenses/LICENSE-2.0)

## Authors
Switchboard is brought to you by [Philipp Berner](https://github.com/philippb) and [Zouhair Belkoura](https://github.com/zouhairb), founders of KeepSafe.
We'd love to have you contribute.

## Contributors
Special thanks goes to our contributors

- [Chris Beauchamp](https://github.com/cjbeauchamp)

## Used in production by
* KeepSafe (www.getkeepsafe.com)