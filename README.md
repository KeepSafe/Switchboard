Switchboard - easy A/B testing for your mobile app
===

## What it does
Switchboard is a simple way to remote control your mobile application even after you shipped it to your users'
devices.
Use switchboard to
* Stage-rollout new features to users
* A/B-test things in your app
* anything you want to remote-control

Switchboard lets you control what happens in your app. Quick, easy, useful.

*Switchboard segments your users consistently.* Because user segmentation is based only on UUID that is computed once, the experience you switch on and off using Switchboard is consistent across sessions.

## What it does not do (what you have to do yourself)
Switchboard does not give you analytics, nor does it automatic administration and optimization of your A/B tests. It also doesn't give you nice graphs and stuff. You can get all of that by plugging an analytics package into your app which you're probably doing anyway.

## How to use it
### Client
Add the DynamicConfigManager package to your project. You only need to initialize the DynamicConficManager at the application start. 
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
		//get remote controlled values from Switchboard
		JSONObject smileValues = Switchboard.getExperimentValueFromJson(myContext, experimentName);

		int smileWidth = smileValues.getInt("width");

		//do something with it
		prepareSmiley(smileWidth);
		showSmileyWelcomeMessage();
	}
```

### Server
The server receives a UUID that the client generated (mandatory) as well as any other parameters that you decided to send.
Here, you configure what the switches on the particular device flip.

Example code of the PHP implementation for a simple on/off switch:

```php
	//put 50% of your users into the showSmiley A/B test
	$resultArray['showSmiley'] = turnOnBucket($uuid, 0, 50);

	//return result array as JSON
	renderResultJson($resultArray);
```

You can do more complex things if you want:

```php
	//put a percentage of users in the test and vary smile width
	$resultArray['showSmiley'] = smileyVariation($uuid, $lang);

	function smileyVariation($uuid, $lang){
		if (empty($uuid))
			return inactiveExperimentReturnArray();

		//turn it on for 50% only
		if (isInBucket($uuid, 0, 50)){

			$values = array();
			//and then vary the values
			if ($lang == "eng"){ //broad smiles in US
				$values['width'] = 10;
			}
			if ($lang == "deu"){ //more subtle in Germany
				$values['width'] = 9;
			}
			return activeExperimentReturnArray($values);
		}

		//default
		return inactiveExperimentReturnArray();
	}
```

## License
TODO Switchboard will probably be distributed under the GPLv3 license

## Authors
Switchboard is brought to you by Philipp Berner and Zouhair Belkoura, founders of KeepSafe.
We'd love to have you contribute.