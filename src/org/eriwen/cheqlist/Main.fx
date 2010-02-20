/*
 *  Copyright 2010 Eric Wendelin
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
package org.eriwen.cheqlist;

import javafx.animation.*;
import javafx.scene.*;
import javafx.scene.image.Image;
import javafx.scene.paint.Color;
import javafx.scene.input.MouseEvent;
import javafx.stage.*;

import java.awt.Desktop;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;
import java.util.concurrent.ExecutionException;

import org.eriwen.rtm.*;
import org.eriwen.cheqlist.util.*;
import org.eriwen.cheqlist.theme.*;

/**
 * Main Cheqlist application script that creates all panes, the thinbar and 
 * handles all RTM data
 *
 * @author Eric Wendelin
 */

package def groovyRtm = new RtmService('c11620c31ac1c7e410f039d41c813a2b', '0ce781140c74257e');
var isApplicationConfigured = false;

/****************
 * Settings
 ****************/
//TODO: implement better configuration management like the one WidgetFX uses
public-read def settings = Settings{};

//Cheqlist position settings
var savedStageX:Number = Number.parseFloat(settings.get('stageX').toString()) on replace {
    settings.put('stageX', savedStageX);
};
var savedStageY:Number = Number.parseFloat(settings.get('stageY').toString()) on replace {
    settings.put('stageY', savedStageY);
};
public var stageX:Number = savedStageX;
public var stageY:Number = savedStageY;

//Setting options on Settings pane
var visualEffectsEnabled:Boolean = settings.get('visualEffectsEnabled') as Boolean on replace {
    settings.put('visualEffectsEnabled', visualEffectsEnabled);
};
var showTooltips:Boolean = settings.get('showTooltips') as Boolean on replace {
    settings.put('showTooltips', showTooltips);
};
var showCompletedTasks:Boolean = settings.get('showCompletedTasks') as Boolean on replace {
    settings.put('showCompletedTasks', showCompletedTasks);
};
var syncIntervalMillis:Integer = Integer.parseInt(settings.get('syncInterval').toString()) on replace {
    settings.put('syncInterval', syncIntervalMillis);
};
var taskSort:String = settings.get('taskSort').toString() on replace {
    settings.put('taskSort', taskSort);
};
var curTimezoneOffset:Integer = Integer.parseInt(settings.get('curTimezoneOffset').toString()) on replace {
    settings.put('curTimezoneOffset', curTimezoneOffset);
};
var taskFilter:String = settings.get('defaultTaskFilter').toString() on replace {
    settings.put('defaultTaskFilter', taskFilter)
};

//Setup colors from user settings
package def theme = DarkTheme {
    foregroundColor: Color.web(settings.get('foregroundColor').toString());
    dueDateTextColor: Color.web(settings.get('secondaryForegroundColor').toString());
    backgroundColor: Color.web(settings.get('backgroundColor').toString());
    overdueTextColor: Color.web(settings.get('overdueColor').toString());
    priority1Color: Color.web(settings.get('priority1Color').toString());
    priority2Color: Color.web(settings.get('priority2Color').toString());
    priority3Color: Color.web(settings.get('priority3Color').toString());
    priorityNColor: Color.web(settings.get('priorityNColor').toString());
};

package def viewUtils = ViewUtils { theme: theme, settings: settings };
package def groovyRtmUtils = GroovyRtmUtils{};
package def strUtils = new StringUtils();
var lists:List = new ArrayList();
var locations:List = new ArrayList();
var rtmsettings:Map = new HashMap();
var tasks:List = new ArrayList();
package var currentEditTask:LinkedHashMap = new LinkedHashMap();

var showThinbarButtons = false;
package var tasksPeriodicSyncTimeline:Timeline = Timeline {
    repeatCount: Timeline.INDEFINITE
    keyFrames: [
        KeyFrame {
            time: bind Duration.valueOf(syncIntervalMillis),
            action: function() { updateTaskList(taskFilter); }
        }
    ]
}

/******************************************************************************
 * Sidebar Panes
 ******************************************************************************/

/* Splash Screen Pane */
def splashScreenPane:SplashScreenPane = SplashScreenPane {
    closeAction: function(e) { viewUtils.closeSidebar(splashScreenPane); }
    theme: bind theme
};

/* Add Task Pane */
def addTaskPane:AddTaskPane = AddTaskPane {
    closeAction: function(e) { viewUtils.closeSidebar(addTaskPane); }
    updateTaskListAction: function() {
        updateTaskList(taskFilter);
    }
    rtm: groovyRtm
    rtmUtils: groovyRtmUtils
    lists: bind lists
    locations: bind locations
    theme: theme
};

/* Edit Task Pane */
def editTaskPane:EditTaskPane = EditTaskPane {
    closeAction: function(e) { viewUtils.toggleSidebar(taskListPane); }
    updateTaskListAction: function() {
        taskListPane.taskFilterBox.commit();
        taskListPane.taskFilterBox.action();
    }
    rtm: groovyRtm
    rtmUtils: groovyRtmUtils
    strUtils: strUtils
    lists: bind lists
    locations: bind locations
    theme: theme
    task: bind currentEditTask
    timezoneOffset: curTimezoneOffset
};

/* Task List Pane */
def taskListPane:TaskListPane = TaskListPane {
    closeAction: function(e) { viewUtils.closeSidebar(taskListPane); }
    editAction: function(task:LinkedHashMap) {
        currentEditTask = task;
        viewUtils.toggleSidebar(editTaskPane);
    }
    updateTaskListAction: updateTaskList
    rtm: groovyRtm
    rtmUtils: groovyRtmUtils
    strUtils: strUtils
    taskFilter: bind taskFilter with inverse
    taskSortType: bind taskSort
    lists: bind lists
    tasks: bind tasks with inverse
    theme: theme
    timezoneOffset: curTimezoneOffset
};

/* Lists Pane */
def listsListPane:ListsPane = ListsPane {
    closeAction: function(e) { viewUtils.closeSidebar(listsListPane); }
    listClickedAction: function(list:String) {
        taskListPane.taskFilterBox.text = 'list:"{list}"';
        taskListPane.taskFilterBox.commit();
        taskListPane.taskFilterBox.action();
        viewUtils.toggleSidebar(taskListPane);
    }
    updateListsAction: updateListsList
    rtm: groovyRtm
    rtmUtils: groovyRtmUtils
    lists: bind lists
    theme: theme
};

/* Settings Pane */
def settingsPane:SettingsPane = SettingsPane {
    closeAction: function(e) { viewUtils.closeSidebar(settingsPane); }
    visualEffects: bind visualEffectsEnabled with inverse
    tooltips: bind showTooltips with inverse
    showCompleted: bind showCompletedTasks with inverse
    syncIntervalMillis: bind syncIntervalMillis with inverse
    taskSortType: bind taskSort with inverse 
    settings: settings
    tasksSyncTimeline: tasksPeriodicSyncTimeline
    logoutAction: function() {
        rtmlogout();
        FX.exit();
    }
    resetAction: function() {
        visualEffectsEnabled = false;
        showTooltips = true;
        showCompletedTasks = false;
        syncIntervalMillis = 900000;
        taskFilter = 'dueBefore: "1 week from today"';
        taskSort = 'smart';
        settings.put('foregroundColor', '#FFFFFF');
        settings.put('backgroundColor', '#000000');
        settings.put('secondaryForegroundColor', '#DDDDDD');
        settings.put('overdueColor', '#FFFF66');
        settings.put('priority1Color', '#EA5500');
        settings.put('priority2Color', '#0060BF');
        settings.put('priority3Color', '#359AFF');
        settings.put('priorityNColor', '#666666');
        FX.exit();
    }
    theme: theme
};

/* Authorize Pane */
def authPane:AuthPane = AuthPane {
    authorizeAction: authorize
    theme: theme
};

def thinbar:Thinbar = Thinbar {
    theme: theme,
    mouseDraggedAction: function(e:MouseEvent) {
        stageX = e.screenX - e.dragAnchorX;
        if (stageX < 0.0) stageX = 0.0;
        
        stageY = e.screenY - e.dragAnchorY;
        if (stageY < 0.0) {
            stageY = 0.0;
        } else if (stageY > Screen.primary.bounds.maxY - theme.stageHeight) {
            stageY = Screen.primary.bounds.maxY - theme.stageHeight;
        }
    }
    mouseReleasedAction:function(e:MouseEvent) {
        //Save Cheqlist position
        savedStageX = stageX;
        savedStageY = stageY;
    }
    showButtons: bind showThinbarButtons
    showTooltips: bind showTooltips
    viewUtils: viewUtils
    addTaskPane: addTaskPane
    taskListPane: taskListPane
    listsListPane: listsListPane
    settingsPane: settingsPane
}

/**
 * Initializes the application by opening the splashscreen, creating the thinbar
 * buttons, and kicking off the auth or caching
 */
function initPanes():Void {
    delete thinbar from authScene.content;
    insert thinbar into mainScene.content;
    viewUtils.thinbar = thinbar;
    isApplicationConfigured = true;
    viewUtils.openSidebar(splashScreenPane);
    if (checkLogin()) {
        updateLists();
        //Kick off syncing tasks every so often
        tasksPeriodicSyncTimeline.playFromStart();
    }
}

/**
 * Checks if we're logged in and handles the auth process if we're not
 */
function login():Void {
    if (not groovyRtm.isAuthenticated()) {
        viewUtils.openAuthSidebar(authPane);
        var authUrl = groovyRtm.getAuthUrl();
        try {
            if (Desktop.isDesktopSupported()) {
                var desktop:Desktop = Desktop.getDesktop();
                desktop.browse(new URI(authUrl));
            } else {
                authPane.toaster.show("Please go here to authorize Cheqlist: {authUrl}");
            }
        } catch (ue: URISyntaxException) {
            ue.printStackTrace();
        }
    } else {
        initPanes();
    }
}

function authorize(me:MouseEvent):Void {
    try {
        groovyRtmUtils.asyncTask(function () {
            var authToken = groovyRtm.getNewAuthToken();
        }, function (result):Void {
            if (result != null) {
                initPanes();
            }
        }, function (e:ExecutionException):Void {
            authPane.toaster.showTimed("Could not authorize Cheqlist, retrying...", 15s);
            login();
        });
    } catch (rtme:RtmServiceException) {
        authPane.toaster.showTimed("Oops! You haven't authorized Cheqlist yet.", 15s);
        login();
    }
}

function rtmlogout():Void {
    println("logout called");
    viewUtils.closeSidebar(splashScreenPane);
    isApplicationConfigured = false;
    groovyRtm.removeAuthToken();
    delete thinbar from mainScene.content;
    insert thinbar into authScene.content;
}

//FIXME: We want to refactor this to wrap each operation and make it synchronous yet not holdup the EDT
function onListsLoaded(result:Object):Void {
    splashScreenPane.progress += 20;
    lists = result as List;
    splashScreenPane.statusMessage = 'Loading locations...';
    updateLocations();
}
function onLocationsLoaded(result:Object):Void {
    splashScreenPane.progress += 20;
    locations = result as List;
    splashScreenPane.statusMessage = 'Loading settings...';
    updateSettings();
}
function onSettingsLoaded(result:Object):Void {
    splashScreenPane.progress += 20;
    rtmsettings = result as HashMap;
    updateTimezone();
}
function onTimezoneLoaded(result:Object):Void {
    splashScreenPane.progress += 20;
    var timezoneValue:String = result as String;
    if (timezoneValue.equals("")) {
        curTimezoneOffset = 0;
    } else {
        curTimezoneOffset = Integer.parseInt(result as String);
    }
    splashScreenPane.statusMessage = 'Loading tasks...';
    updateTasks();
}
function onTasksLoaded(result:Object):Void {
    splashScreenPane.progress += 20;
    onTasksSync(result);
    isApplicationConfigured = true;
    showThinbarButtons = true;
    viewUtils.closeSidebar(splashScreenPane);
}

/**
 * Checks if we're really logged into RTM and resets the app if not
 *
 * @return True if we are logged in
 */
function checkLogin():Boolean {
    try {
        return groovyRtm.testLogin();
    } catch(rtme:RtmServiceException) {
        rtme.printStackTrace();
        rtmlogout();
        login();
        return false;
    }
}

function updateLists():Void {
    groovyRtmUtils.loadRtmCollection(function() { return groovyRtm.listsGetList(); }, onListsLoaded);
}
function updateLocations():Void {
    groovyRtmUtils.loadRtmCollection(function() { return groovyRtm.locationsGetList(); }, onLocationsLoaded);
}
function updateSettings():Void {
    groovyRtmUtils.loadRtmCollection(function() { return groovyRtm.settingsGetList(); }, onSettingsLoaded);
}
function updateTimezone():Void {
    groovyRtmUtils.loadRtmCollection(function() {
        return groovyRtm.timezonesGetTimezoneByName(rtmsettings.get('timezone').toString()).get('currentOffset').toString();
    }, onTimezoneLoaded);
}
function updateTasks():Void {
    groovyRtmUtils.loadRtmCollection(function() { 
        var amendedFilter = taskFilter;
        if (not showCompletedTasks) {
            amendedFilter = "status:incomplete and {taskFilter}";
        }
        return groovyRtm.tasksGetList(null, amendedFilter);
    }, onTasksLoaded);
}

function updateTaskList(filter:String):Void {
    groovyRtmUtils.loadRtmCollection(function() {
        var amendedFilter = filter;
        if (not showCompletedTasks) {
            amendedFilter = "status:incomplete and {filter}";
        }
        return groovyRtm.tasksGetList(null, amendedFilter);
    }, onTasksSync);
}

function updateListsList():Void {
    groovyRtmUtils.loadRtmCollection(function() {
        return groovyRtm.listsGetList()
    }, onListsSync);
}

package function refreshTasksList():Void {
    var tmpTasks = tasks;
    taskListPane.tasks = new ArrayList();
    taskListPane.tasks = tmpTasks;
}

function onTasksSync(result:Object):Void {
    //Try to release old tasks for GC
    tasks = new ArrayList();
    tasks = result as List;
}

function onListsSync(result:Object):Void {
    lists = result as List;
}

/**
 * Function called upon application startup. Will login and then add an action
 * to save settings upon shutdown
 */
public function run() {
    //viewUtils.showSystemTrayIcon();
    login();
    FX.addShutdownAction(settings.saveSettings);
}

// Scene to be shown if the application is authorized
public def mainScene:Scene = Scene {
    content: []
    width: theme.stageWidth, height: theme.stageHeight
}

// Scene to be shown while we're not authorized
public def authScene:Scene = Scene {
    content: [thinbar]
    fill: theme.backgroundColor
    width: theme.stageWidth - theme.thinbarWidth, height: theme.stageHeight
}

def stage = Stage {
    title: 'Cheqlist'
    icons: [ 
        Image { url: theme.icon16ImageUrl, width: 16, height: 16 },
        Image { url: theme.icon32ImageUrl, width: 32, height: 32 },
        Image { url: theme.icon64ImageUrl, width: 64, height: 64 }
    ]
    x: bind stageX, y: bind stageY
    width: bind theme.stageWidth, height: theme.stageHeight
    style: StageStyle.UNDECORATED
    resizable: false
    scene: bind if (isApplicationConfigured) then mainScene else authScene
    onClose: function() { FX.exit() }
}
