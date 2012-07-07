package com.keepsafe.switchboard.example;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.TextView;

import com.keepsafe.switchboard.AsyncConfigLoader;
import com.keepsafe.switchboard.SwitchBoard;

public class SwitchBoardExampleAppActivity extends Activity {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        //Initializes the default URLs the first time. 
        SwitchBoard.initDefaultServerUrls("http://your-domain/path_to/currentServerUrl.php", "http://your-domain/path_to/config.php", true);
        
        /* Looks at the server if there are changes in the server URL that should be used in the future
         * 
         * In production you should be loaded asynchronous with AsyncConfigLoader.
         * new AsyncConfigLoader(this, AsyncConfigLoader.UPDATE_SERVER);
         */
        SwitchBoard.updateConfigServerUrl(this);
        
        
        /* Loads the actual config. This can be done on app start or on app onResume().
         * depending how often you want to update the config.
         *  
         * In production you should be loaded asynchronous with AsyncConfigLoader.
         * new AsyncConfigLoader(this, AsyncConfigLoader.CONFIG_SERVER);
         */ 
        SwitchBoard.loadConfig(this);
        
        setContentView(R.layout.main);
    }
    
    @Override
    protected void onResume() {
    	super.onResume();
    	//see if we're in experiment "homeScreenMessage" that we defined on the server
        if(SwitchBoard.isInExperiment(this, "homeScreenMessage")) {
        	
        	//check if the experiment has values. Only needed when passing custom variables
        	if(SwitchBoard.hasExperimentValues(this, "homeScreenMessage")) {
        		TextView tv = (TextView) findViewById(R.id.messagebox);	
        		tv.setVisibility(View.VISIBLE);
        		
        		//get experiment values
        		JSONObject values = SwitchBoard.getExperimentValueFromJson(this, "homeScreenMessage");
        		try {
        			//getting the user specific values
					String message = values.getString("message");
					String messageTitle = values.getString("messageTitle");
					
					tv.setText(message);
					
					/* Track the view in your preferred analytics
					 * using messageTitle to track test 
					 */
					
					//tracks when user clicks on HTML link from your A/B test
					tv.setOnClickListener(new OnClickListener() {
						
						@Override
						public void onClick(View v) {
							/* Track the click in your preferred analytics
							 * using messageTitle to track test 
							 */
						}
					});
					
					
				} catch (JSONException e) {
					//catches if your requested JSON object is not in values
					e.printStackTrace();
				}
        	}	
        }
    }
    
    public void goNext(View v){
    	Intent i;
    	
    	//gives users a different activity when they are in A/B test
    	//example on how to test user flows
    	if(SwitchBoard.isInExperiment(this, "nextActivityTest"))
    		i = new Intent(this, NextActivityTest.class);
    	else
    		i = new Intent(this, NextActivityNormal.class);
    	
    	startActivity(i);
    }
}