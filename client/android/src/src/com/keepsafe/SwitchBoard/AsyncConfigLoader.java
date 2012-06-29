package com.keepsafe.SwitchBoard;

import android.content.Context;
import android.os.AsyncTask;

/**
 * An async loader to load user config in background thread based on internal generated UUID.
 * @author philipp
 *
 */
public class AsyncConfigLoader extends AsyncTask<Void, Void, Void> {

	Context context;
	public AsyncConfigLoader(Context c) {
		this.context = c;
	}
	@Override
	protected Void doInBackground(Void... params) {
		SwitchBoard.loadConfig(context);
		return null;
	}
	
}