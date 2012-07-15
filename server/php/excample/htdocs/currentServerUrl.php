<?php

$returnArray = array(
	//path to this file
	'updateServerUrl' => "http://switchboard.herokuapp.com/currentServerUrl.php",
	
	//path to config.php file where the actual dynamic config is generated
	'configServerUrl' => "http://switchboard.herokuapp.com/config.php"
);

header('Content-type: application/json');
echo json_encode($returnArray);
?>