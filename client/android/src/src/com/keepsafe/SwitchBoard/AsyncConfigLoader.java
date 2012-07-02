package com.keepsafe.SwitchBoard;

import android.content.Context;
import android.os.AsyncTask;

/**
 * An async loader to load user config in background thread based on internal generated UUID.
 * 
 * Call <code>AsyncConfigLoader.execute()</code> to load SwitchBoard.loadConfig() with own ID. 
 * To use your custom UUID call <code>AsyncConfigLoader.execute(uuid)</code> with uuid being your unique user id
 * as a String 
 *
 * @author philipp
 *
 */
public class AsyncConfigLoader extends AsyncTask<String, Void, Void> {

	Context context;
	public AsyncConfigLoader(Context c) {
		this.context = c;
	}
	
	
	@Override
	protected Void doInBackground(String... params) {
		//use custom UUID when set
		if(params.length == 1) {
			String uuid = params[0];
			SwitchBoard.loadConfig(context, uuid);
		} else
			SwitchBoard.loadConfig(context);
		
		return null;
	}
	
}