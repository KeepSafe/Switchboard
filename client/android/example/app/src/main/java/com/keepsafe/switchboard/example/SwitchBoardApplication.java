package com.keepsafe.switchboard.example;

import android.app.Application;
import android.util.Log;

import com.keepsafe.switchboard.SwitchBoard;

public class SwitchBoardApplication extends Application {

    private static final String TAG = "SwitchBoardExampleApp";

    @Override
    public void onCreate() {
        super.onCreate();

        new Thread(new Runnable() {
            @Override
            public void run() {
                //Initializes the default URLs the first time.
                Log.d(TAG, "init Server Urls");
                SwitchBoard.initDefaultServerUrls("http://switchboard.herokuapp.com/SwitchboardURLs.php", "http://switchboard.herokuapp.com/SwitchboardDriver.php", true);

                /* Looks at the server if there are changes in the server URL that should be used in the future
                 *
                 * In production you should be loaded asynchronous with AsyncConfigLoader.
                 * new AsyncConfigLoader(this, AsyncConfigLoader.UPDATE_SERVER);
                 */
                Log.d(TAG, "update server urls from remote");
                SwitchBoard.updateConfigServerUrl(SwitchBoardApplication.this);
            }
        }).start();
    }
}
