<?php

/* Possible params
 * $lang - Device language
 * $manufacturer - Device manufacturer
 * $device - device model name
 * $uuid - client side generated unique user id
 * $country - device country
 * $version - app version
 * $appId - aalication id. packageName for android SDK
 */
$lang;
$manufacturer;
$device;
$uuid;
$country;
$version;
$appId;


setGetParams($_GET);

/** Returns true if the requesting user is within the defined bucket. 
  * $low is included and $high is excluded.
  */
function isInBucket($uuid, $low, $high) {
	$userBucket = getUserBucket($uuid);
	if ($userBucket >= $low && $userBucket < $high) 
		return true;
	else
		return false;
}

/** The quickest way to generate an A/B test. Sets experiment to active when user is with the defined bucked.
  * $low cincluding, $high excluding
  */
function turnOnBucket($uuid, $low, $high) {
	if(empty($uuid)) 
		return inactiveExperimentReturnArray();
	
	//define buckets for experiment
	if(isInBucket($uuid, $low, $high))
		return activeExperimentReturnArray();
	else
		return inactiveExperimentReturnArray();
}

/**
  * Helps to manage multiple applications for A/B testing.
*/
function isApplicationId($applicationId) {
	if($applicationId == $appId)
		return true;
	else
		return false;
}

/** Gives a relt array fora an experiemnt the user is part of. Optional takes a array of values that can 
  * be received at the client.
  */
function activeExperimentReturnArray($values = null) {
	return array('isActive' => true,
				'values' => $values);		
}

/** Returns the result array when a user is not in the experiment */
function inactiveExperimentReturnArray() {
	return array('isActive' => false,
				'values' => null);		
}

/** Renders all experiment values as JSON string and returns it as result */
function renderResultJson($resultArray) {
	header('Content-type: application/json');
	echo json_encode($resultArray);
}

/********************************************************************************/
/************** internal functions, not need for creat experiments **************/
/********************************************************************************/

/**
  * Return the bucket number of the user. There a 100 possible buckes.
  */  
function getUserBucket($uuid) {
	$lastChars = substr($uuid, -5);
	
	$segmentId = $lastChars[0];
	
	for($i = 1; $i < strlen($lastChars); $i++){
		$segmentId = ($segmentId << 3) + ord($lastChars[$i]);
	}
	
	$segment = substr($segmentId, -2);
	
	return $segment;
}


/** Sets all supported params from GET url */
function setGetParams($appParams) {
	global $lang, $manufacturer, $device, $uuid, $country, $version, $appId;
	
	$uuid = getArrayParam($appParams, 'uuid');
	$device = getArrayParam($appParams, 'device');
	$manufacturer = getArrayParam($appParams, 'manufacturer');
	$lang = getArrayParam($appParams, 'lang');
	$version = getArrayParam($appParams, 'version');
	$country = getArrayParam($appParams, 'country');
	$appId = getArrayParam($appParams, 'appId');
}

function getArrayParam($array, $paramName){
	if(isset($array[$paramName])) 
		return $array[$paramName];
	else
		return "";
}


?>