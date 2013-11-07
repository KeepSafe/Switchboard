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

class SwitchboardExperiments {

    var $manager;
    
    function __construct($manager) {
        $this->manager = $manager;
    }    
    
    /** Sample experiment that gives 20% of the users a message. Those 20% are divided into two groups that
      * get to see a different message
      */
    function sample() {

    	if(empty($this->manager->uuid))
    		return $this->manager->inactiveExperimentReturnArray();
    	
    	//turn experiment on for bucket 0-19. First 20% of the users
    	if($this->manager->isInBucket(0, 20)) {

    		//return values
    		$values = array();
    		
    		//Filter for only users with english language settings
    		if($this->manager->lang == "eng") {
    		
    			//first 10% of the user see this message
    			if($this->manager->isInBucket(0, 10)){
    			
    				//message that you want to display in the app
    				$values['message'] = 'IMPORTANT! Get KeepSafe: <a href="market://details?id=com.kii.safe">click HERE.</a>'; 
    				
    				//message title that you give your analytics enging to track what version the user saw
    				$values['messageTitle'] = 'get KeepSafe ver 1';
    
    				return $this->manager->activeExperimentReturnArray($values);
    				
    			//the other 10% of the user see another message
    			} else {
    				$values['message'] = 'Please download KeepSafe: <a href="market://details?id=com.kii.safe">click HERE.</a>'; 
    				$values['messageTitle'] = 'get KeepSafe ver 2';
    				    
    				return $this->manager->activeExperimentReturnArray($values);
    			}		
    		} else {
    				$values['message'] = 'You are not an english user dude. So the message is not displayed'; 
    				$values['messageTitle'] = 'get KeepSafe ver 2';
    				    
    				return $this->manager->activeExperimentReturnArray($values);
    		}
    	}
    	
    	//user is not in experiment as default
    	return $this->manager->inactiveExperimentReturnArray();
    }

    
};

?>