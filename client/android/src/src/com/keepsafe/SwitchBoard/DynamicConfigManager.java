package com.keepsafe.SwitchBoard;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.util.Hashtable;
import java.util.Locale;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Build;
import android.util.Log;


public class DynamicConfigManager {

	private static final String TAG = "DynamicConfigManager";
	public static final boolean DEBUG = false;
	
	//staging server
	private static final String DYNAMIC_CONFIG_SERVER_URL_UPDATE_STAGING = "http://staging.domain/path_to/currentServerUrl.php";
	private static final String DYNAMIC_CONFIG_SERVER_DEFAULT_URL_STAGING = "http://staging.domain/path_to/config.php";
	
	//production server
	private static final String DYNAMIC_CONFIG_SERVER_URL_UPDATE = "http://domain/path_to/currentServerUrl.php";
	private static final String DYNAMIC_CONFIG_SERVER_DEFAULT_URL = "http://domain/path_to/config.php";
	
	
	
	//dynamic config
	public static final String IS_EXPERIMENT_ACTIVE = "isActive";
	public static final String EXPERIMENT_VALUES = "values";
	
	//dynamic config server
	public static final String getDynamicConfigServerUrlUpdate() {
		if(DEBUG)
			return DYNAMIC_CONFIG_SERVER_URL_UPDATE_STAGING;
		else
			return DYNAMIC_CONFIG_SERVER_URL_UPDATE;
	}
	
	public static final String getDynamicConfigServerDefaultUrl() {
		if(DEBUG)
			return DYNAMIC_CONFIG_SERVER_DEFAULT_URL_STAGING;
		else
			return DYNAMIC_CONFIG_SERVER_DEFAULT_URL;
	}
	
	/**
	 * Updates the config server URL where the manager is getting is config files from
	 * Use this method only in background thread as network connections are involved that block UI thread.
	 */
	public static void initConfigServerUrl(Context c) {
		Log.d(TAG, "start initConfigServerUrl");
		
		//lookup new config server url from the one that is in shared prefs
		String updateServerUrl = Preferences.getDynamicUpdateServerUrl(c);
		
		//set to default when not set in preferences
		if(updateServerUrl == null) 
			updateServerUrl = DYNAMIC_CONFIG_SERVER_URL_UPDATE;

		
		
		try {
			
			
			String result = readFromUrlGET(updateServerUrl, "");
			Log.d(TAG, "Result String: " + result);
			
			if(result != null){
				JSONObject a = new JSONObject(result);
				
				Preferences.setDynamicConfigServerUrl(c, (String)a.get("updateServerUrl"), (String)a.get("configServerUrl"));
				
				Log.d(TAG, "Update Server Url: " + (String)a.get("updateServerUrl"));
				Log.d(TAG, "Config Server Url: " + (String)a.get("configServerUrl"));
			} else {
				String configUrl = Preferences.getDynamicConfigServerUrl(c);
				String updateUrl = Preferences.getDynamicUpdateServerUrl(c);
					
				if(configUrl == null)
					configUrl = DYNAMIC_CONFIG_SERVER_DEFAULT_URL;
				
				if(updateUrl == null)
					updateUrl = DYNAMIC_CONFIG_SERVER_URL_UPDATE;
				
				Preferences.setDynamicConfigServerUrl(c, updateUrl, configUrl);
			}
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		
		
		Log.d(TAG, "end initConfigServerUrl");
		
		
		//Preferences.setDynamicConfigServerUrl(c, updateServerUrl, configServerUrl)
	}
	
	/**
	 * Loads a new config file for the specific user from current config server.
	 * Use initConfigServerUrl to update the config server url.
	 * Use this method only in background thread as network connections are involved that block UI thread.
	 */
	public static void loadConfig(Context c) {
		loadConfig(c, null);
	}

	public static void loadConfig(Context c, String uuid) {
		
		try {
			//get uuid
			Hashtable<String, String> specs = Util.getSystemParams(c);
			
			//take SwitchBoard util UUID if user has not specified by himself.
			if(uuid == null)
				uuid = specs.get(Util.UUID);
			
			String device = Build.DEVICE;
			String lang = Locale.getDefault().getISO3Language();
			
			//load config for all experiments
			String serverUrl = Preferences.getDynamicConfigServerUrl(c);
			
			if(serverUrl != null) {
				URL url = new URL(serverUrl);
				String serverConfig = readFromUrlGET(serverUrl, "uuid="+uuid+"&device="+device+"&lang="+lang);
				
				Log.d(TAG, serverConfig);
				
				//store experiments in shared prefs (one variable)
				if(serverConfig != null)
					Preferences.setDynamicConfigJson(c, serverConfig);
			}
			
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (NullPointerException e) {

		}
		
	}
	
	/**
	 * Looks up in config if user is in certain experiment.
	 * Experiment names are defined server side and documented in wiki.
	 * https://sites.google.com/a/getkeepsafe.com/wiki/config-framework/current-experiments
	 * @param experimentName Name of the experiment to lookup
	 * @return returns value for experiment and false if experiment does not exist.
	 */
	public static boolean isInExperiment(Context c, String experimentName) {
		//lookup experiment in config
		String config = Preferences.getDynamicConfigJson(c);
		
		//if it does not exist
		if(config == null)
			return false;
		else {
			
			try {
				JSONObject experiment = (JSONObject) new JSONObject(config).get(experimentName);
				Log.d(TAG, "experiment " + experimentName + " JSON object: " + experiment.toString());
				if(experiment == null)
					return false;
				
				boolean returnValue = false;
				returnValue = experiment.getBoolean(IS_EXPERIMENT_ACTIVE);
				
				return returnValue;
			} catch (JSONException e) {
				Log.e(TAG, "Config: " + config);
				e.printStackTrace();
				
			}
		
			//return false when JSON fails
			return false;
		}
		
	}
	
	public static boolean hasExperimentValues(Context c, String experimentName) {
		if(getExperimentValueFromJson(c, experimentName) == null)
			return false;
		else
			return true;
	}
	
	/**
	 * Returns the experiment value as a string. Depending on what experiment is has to be converted to the right type.
	 * Conversion is by convention.
	 * @param experimentName Name of the experiment to lookup
	 * @return Experiment value as String, null if experiment does not exist.
	 */
	public static JSONObject getExperimentValueFromJson(Context c, String experimentName) {
		String config = Preferences.getDynamicConfigJson(c);
		
		if(config == null)
			return null;
		
		JSONObject json = null;
		try {
			JSONObject experiment = (JSONObject) new JSONObject(config).get(experimentName);
			
			JSONObject values = experiment.getJSONObject(EXPERIMENT_VALUES);
			
			
			return values;
			
		} catch (JSONException e) {
			Log.e(TAG, "Config: " + config);
			e.printStackTrace();
			Log.e(TAG, "Could not create JSON object from config string", e);
		}
		
		return null;
	}
	
	/**
	 * Returns a String containing the server response from a GET request
	 * @param address Valid http addess.
	 * @param params String of params. Multiple params seperated with &. No leading ? in string
	 * @return Returns String from server or null when failed.
	 */
	private static String readFromUrlGET(String address, String params) {
		if(address == null || params == null)
			return null;
		
		String completeUrl = address + "?" + params;
		Log.d(TAG, "readFromUrl(): " + completeUrl);
		
		try {
			URL url = new URL(completeUrl);
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("GET");
			connection.setUseCaches(false);
			connection.setDoOutput(true);

			// get response
			InputStreamReader inputStreamReader = new InputStreamReader(connection.getInputStream());
			BufferedReader bufferReader = new BufferedReader(inputStreamReader, 8192);
			String line = "";
			String resultContent = "";
			while ((line = bufferReader.readLine()) != null) {
				Log.d(TAG, line);
				resultContent += line;
				
			}
			bufferReader.close();
			
			Log.d(TAG, "readFromUrl() result: " + resultContent);
			
			return resultContent;
		} catch (ProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		return null;
	}
	
	public class AsyncConfigLoader extends AsyncTask<Void, Void, Void> {

		Context context;
		public AsyncConfigLoader(Context c) {
			this.context = c;
		}
		@Override
		protected Void doInBackground(Void... params) {
			DynamicConfigManager.loadConfig(context);
			return null;
		}
		
	}

}
