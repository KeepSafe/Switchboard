<?php

require_once("SwitchboardConfig.php");

$returnArray = array(
	//path to this file
	'updateServerUrl' => UPDATE_SERVER_URL,
	
	//path to config.php file where the actual dynamic config is generated
	'mainServerUrl' => MAIN_SERVER_URL
);

header('Content-type: application/json');
echo json_encode($returnArray);
?>