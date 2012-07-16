<?php
/*
 * SwitchBoardConfigManager provides the core functionality for the SwitchBoard A/B testing framework.
 * This file offers a bunch of helper methodes that you can use to generate a valid config file for your client.
 * It also contains the core function to split users into different consitent buckets.
 *
 * @author Philipp Berner
 * Licence: TODO
 */

class SwitchboardManager {

    /* Possible params
     * $lang - Device language
     * $manufacturer - Device manufacturer
     * $device - device model name
     * $uuid - client side generated unique user id
     * $country - device country
     * $version - app version
     * $appId - aalication id. packageName for android SDK
     */
    var $lang;
    var $manufacturer;
    var $device;
    var $uuid;
    var $country;
    var $version;
    var $appId;
    
    function __construct($params) {
    	$this->uuid = $this->getArrayParam($params, 'uuid');
    	$this->device = $this->getArrayParam($params, 'device');
    	$this->manufacturer = $this->getArrayParam($params, 'manufacturer');
    	$this->lang = $this->getArrayParam($params, 'lang');
    	$this->version = $this->getArrayParam($params, 'version');
    	$this->country = $this->getArrayParam($params, 'country');
    	$this->appId = $this->getArrayParam($params, 'appId');
    }    
    
    /** Returns true if the requesting user is within the defined bucket. 
      * $low is included and $high is excluded.
      */
    function isInBucket($low, $high) {
    	$userBucket = $this->getUserBucket($this->uuid);
    	if ($userBucket >= $low && $userBucket < $high) 
    		return true;
    	else
    		return false;
    }
    
    /** The quickest way to generate an A/B test. Sets experiment to active when user is with the defined bucked.
      * $low cincluding, $high excluding
      */
    function turnOnBucket($low, $high) {
    	if(empty($this->uuid)) 
    		return $this->inactiveExperimentReturnArray();
    	
    	//define buckets for experiment
    	if($this->isInBucket($low, $high))
    		return $this->activeExperimentReturnArray();
    	else
    		return $this->inactiveExperimentReturnArray();
    }
    
    /**
      * Helps to manage multiple applications for A/B testing.
    */
    function isApplicationId($applicationId) {
    	if($applicationId == $this->appId)
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
    function getUserBucket() {
    
    	$lastChars = substr($this->uuid, -5);
    	
    	$segmentId = $lastChars[0];
    	
    	for($i = 1; $i < strlen($lastChars); $i++){
    		$segmentId = ($segmentId << 3) + ord($lastChars[$i]);
    	}
    	
    	$segment = substr($segmentId, -2);
    	
    	return $segment;
    }
    
    function getArrayParam($array, $paramName){
    	if(isset($array[$paramName])) 
    		return $array[$paramName];
    	else
    		return "";
    }


};

?>