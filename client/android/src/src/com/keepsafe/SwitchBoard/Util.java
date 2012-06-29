/**
 * 
 */
package com.keepsafe.SwitchBoard;

import java.util.Hashtable;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Build;

/**
 * @author philipp
 *
 */
public class Util {
	
	//system params
	public static final String APP_VERSION = "app_version";
	public static final String FIRMWARE = "firmware";
	public static final String MODEL = "model";
	public static final String UUID = "uuid";

	/**
	 * Gets a HashTable with the following system params:
	 * - model
	 * - app_version
	 * - firmware
	 * - uuid
	 * @param context
	 * @return
	 */
	public static Hashtable<String, String> getSystemParams(Context context) {
		Hashtable<String, String> table = new Hashtable<String, String>();
		
		String uuid = getUuid(context);
		if(uuid == null)
			uuid = "";
		
		String version = getAppVersion(context);
		if(version == null)
			version = "null";

		table.put(MODEL, Build.MODEL);
		table.put(FIRMWARE, Build.VERSION.RELEASE);
		table.put(APP_VERSION, version);
		table.put(UUID, uuid);
		
		return table;
	}
	
	private static String getAppVersion(Context context) {
		PackageInfo pInfo;
		try {
			pInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
			return pInfo.versionName;
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		
		return null;
	}

	private static String getUuid(Context context) {
		try {
			DeviceUuidFactory factory = new DeviceUuidFactory(context);
			
			if(factory != null)
				return factory.getDeviceUuid().toString();
			
		} catch (Exception e1) {
			e1.printStackTrace();
		}
		
		return null;
	}
}
