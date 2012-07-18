<?php
/*
   Copyright 2012 KeepSafe Software Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

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