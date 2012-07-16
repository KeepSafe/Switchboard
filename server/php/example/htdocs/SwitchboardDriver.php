<?php

ini_set('display_errors', 1);

require_once("SwitchboardConfig.php");
require_once('SwitchboardManager.php');
require_once('SwitchboardExperiments.php');

$manager = new SwitchboardManager($_GET);
$experiments = new SwitchboardExperiments($manager);

/* Possible params
 * $lang - Device language
 * $manufacturer - Device manufacturer
 * $device - device model name
 * $uuid - client side generated unique user id
 * $country - device country
 * $version - app version
 */

//result experiment array
$resultArray = array();

//pin message
$resultArray['homeScreenMessage'] = $experiments->sample();
$resultArray['nextActivityTest'] = $manager->turnOnBucket(0, 50);


//return result array as JSON
$manager->renderResultJson($resultArray);

?>