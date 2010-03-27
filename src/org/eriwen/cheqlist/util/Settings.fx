/*
 *  Copyright 2009 Eric Wendelin
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package org.eriwen.cheqlist.util;

import java.io.*;
import java.util.*;
import javafx.io.*;

/**
 * @author Eric Wendelin
 */

public class Settings extends Serializable {

    def settingsFile = Storage { source: "cheqlist.props" }
    var defaultAppSettings:HashMap = new HashMap();
    public var appSettings:HashMap = new HashMap();
    public var lists:List = new ArrayList();
    public var locations:List = new ArrayList();
    public var rtmSettings:Map = new HashMap();
    public var tasks:List = new ArrayList();

    init {
        defaultAppSettings.put("stageX", 0.0);
        defaultAppSettings.put("stageY", 50.0);
        defaultAppSettings.put("visualEffectsEnabled", false);
        defaultAppSettings.put("showTooltips", true);
        defaultAppSettings.put("taskSort", 'smart');
        defaultAppSettings.put("showCompletedTasks", false);
        defaultAppSettings.put("defaultTaskFilter", 'dueBefore:"1 week from today"');
        defaultAppSettings.put("syncInterval", 900000);
        defaultAppSettings.put("foregroundColor", "#FFFFFF");
        defaultAppSettings.put("secondaryForegroundColor", "#DDDDDD");
        defaultAppSettings.put("backgroundColor", "#000000");
        defaultAppSettings.put("overdueColor", "#FFFF66");
        defaultAppSettings.put("priority1Color", "#FF3300");
        defaultAppSettings.put("priority2Color", "#0000FF");
        defaultAppSettings.put("priority3Color", "#6699FF");
        defaultAppSettings.put("priorityNColor", "#666666");
        loadSettings();
    }

    public function get(key:Object) {
        //println("getting {key} - {appSettings.get(key)}");
        return appSettings.get(key);
    }

    public function put(key:Object, value:Object) {
        //println("putting {key} - {value}");
        appSettings.put(key, value);
    }

    public function loadSettings() {
        //println('loading settings');
        if (settingsFile.resource.readable) {
            var is:InputStream;
            var settingsInputStream:ObjectInputStream;
            try {
                is = settingsFile.resource.openInputStream();
                settingsInputStream = new ObjectInputStream(is);
                appSettings = settingsInputStream.readObject() as HashMap;
                lists = settingsInputStream.readObject() as ArrayList;
                locations = settingsInputStream.readObject() as ArrayList;
                rtmSettings = settingsInputStream.readObject() as HashMap;
                tasks = settingsInputStream.readObject() as ArrayList;
            } catch (ioe:EOFException) {
                println('settings file not accessible, creating a new one');
            } catch (ioe:IOException) {
                ioe.printStackTrace();
            } finally {
                settingsInputStream.close();
                is.close();
            }
        }

        //For settings that don't exist set default value to be stored later
        var it:Iterator = defaultAppSettings.entrySet().iterator();
        while (it.hasNext()) {
            var entry:Map.Entry = it.next() as Map.Entry;
            if (this.get(entry.getKey()) == null) {
                this.put(entry.getKey(), entry.getValue());
            } 
        }
    }

    public function saveSettings() {
        //println('saving settings');
        if (settingsFile.resource.writable) {
            var os:OutputStream;
            var settingsOutputStream:ObjectOutputStream;
            try {
                os = settingsFile.resource.openOutputStream(true);
                settingsOutputStream = new ObjectOutputStream(os);
                settingsOutputStream.writeObject(appSettings);
                settingsOutputStream.writeObject(lists);
                settingsOutputStream.writeObject(locations);
                settingsOutputStream.writeObject(rtmSettings);
                settingsOutputStream.writeObject(tasks);
            } catch (ioe:IOException) {
                ioe.printStackTrace();
            } finally {
                settingsOutputStream.close();
                os.close();
            }
        }
    }
}
