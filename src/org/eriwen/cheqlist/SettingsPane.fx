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

import javafx.scene.*;
import javafx.scene.control.Label;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.effect.ColorAdjust;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.paint.Color;

import org.jfxtras.scene.layout.XMigLayout;
import org.jfxtras.scene.layout.XMigLayout.*;

import org.eriwen.cheqlist.control.ColorPicker;
import org.eriwen.cheqlist.control.SelectBox;
import org.eriwen.cheqlist.control.SelectBoxItem;
import org.eriwen.cheqlist.util.Settings;
import javafx.animation.Timeline;

/**
 * Pane containing cheqlist settings
 * 
 * @author Eric Wendelin
 */

package class SettingsPane extends Pane {

    package var visualEffects:Boolean;
    package var tooltips:Boolean;
    package var showCompleted:Boolean;
    package var syncIntervalMillis:Integer;
    package var taskSortType:String;
    public-init var logoutAction:function();
    public-init var resetAction:function();
    public-init var settings:Settings;
    public-init var tasksSyncTimeline:Timeline;

    function createLabel(text:String) {
        Label { 
            text: text, textFill: bind theme.foregroundColor,
            layoutInfo: LayoutInfo { width: 180, height: 26 }
            font: theme.normalFont
        }
    }

    def enableVisualEffectsCheckbox:CheckBox = CheckBox {
        allowTriState: false, selected: bind visualEffects with inverse
        onMouseClicked: function(e: MouseEvent) {
            visualEffects = (e.node as CheckBox).selected;
            if (visualEffects) {
                toaster.showTimed("Animations enabled");
            } else {
                toaster.showTimed("Animations disabled");
            }
        }
    }

    def showTooltipsCheckbox:CheckBox = CheckBox {
        allowTriState: false, selected: bind tooltips with inverse
        translateX: 15
        onMouseClicked: function(e: MouseEvent) {
            tooltips = (e.node as CheckBox).selected;
            if (tooltips) {
                toaster.showTimed("Tooltips enabled");
            } else {
                toaster.showTimed("Tooltips disabled");
            }
        }
    }

    def showCompletedCheckbox:CheckBox = CheckBox {
        allowTriState: false, selected: bind showCompleted with inverse
        onMouseClicked: function(e: MouseEvent) {
            showCompleted = (e.node as CheckBox).selected;
            if (showCompleted) {
                toaster.showTimed("Completed tasks can be shown now");
            } else {
                toaster.showTimed("Completed tasks will not be shown");
            }
        }
    }

    def syncIntervalSelectBox:SelectBox = SelectBox {
        options: [
            SelectBoxItem { text: '1 minute', value: '60000' }
            SelectBoxItem { text: '2 minutes', value: '120000' }
            SelectBoxItem { text: '5 minutes', value: '300000' }
            SelectBoxItem { text: '15 minutes', value: '900000' }
            SelectBoxItem { text: '1 hour', value: '3600000' }
            SelectBoxItem { text: 'Never', value: '999999999' }
        ]
        layoutInfo: LayoutInfo { width: 80, height: 26 }
    }
    var syncInterval:String = bind (syncIntervalSelectBox.selectedItem as SelectBoxItem).value.toString() on replace {
        var syncIntervalString = (syncIntervalSelectBox.selectedItem as SelectBoxItem).value.toString();
        if (syncIntervalString != null and syncIntervalString != "") {
            syncIntervalMillis = Integer.parseInt(syncIntervalString);
            tasksSyncTimeline.stop();
            tasksSyncTimeline.playFromStart();
        }
    }

    var currentColor:Color = null;
    var currentColorStr:String = null;
    var colorsInitialized:Boolean = false;
    def colorPicker:ColorPicker = ColorPicker { color: currentColor, colorStr: currentColorStr };
    var color:Color = bind colorPicker.color with inverse on replace {
        if (colorsInitialized) {
            if (currentColorSetting.equals('foregroundColor')) {
                theme.foregroundColor = colorPicker.color;
            } else if (currentColorSetting.equals('secondaryForegroundColor')) {
                theme.dueDateTextColor = colorPicker.color;
            } else if (currentColorSetting.equals('backgroundColor')) {
                theme.backgroundColor = colorPicker.color;
            } else if (currentColorSetting.equals('overdueColor')) {
                theme.overdueTextColor = colorPicker.color;
            } else if (currentColorSetting.equals('priority1Color')) {
                theme.priority1Color = colorPicker.color;
            } else if (currentColorSetting.equals('priority2Color')) {
                theme.priority2Color = colorPicker.color;
            } else if (currentColorSetting.equals('priority3Color')) {
                theme.priority3Color = colorPicker.color;
            } else if (currentColorSetting.equals('priorityNColor')) {
                theme.priorityNColor = colorPicker.color;
            }
            settings.put(currentColorSetting, colorPicker.colorStr);
            Main.refreshTasksList();
        }
    }

    def colorSettingSelectBox:SelectBox = SelectBox {
        options: [
            SelectBoxItem { text: 'Foreground', value: 'foregroundColor' }
            SelectBoxItem { text: 'Secondary', value: 'secondaryForegroundColor' }
            SelectBoxItem { text: 'Background', value: 'backgroundColor' }
            SelectBoxItem { text: 'Overdue', value: 'overdueColor' }
            SelectBoxItem { text: 'High Priority', value: 'priority1Color' }
            SelectBoxItem { text: 'Medium Priority', value: 'priority2Color' }
            SelectBoxItem { text: 'Low Priority', value: 'priority3Color' }
            SelectBoxItem { text: 'No Priority', value: 'priorityNColor' }
        ]
        layoutInfo: LayoutInfo { width: 150, height: 26 }
    }
    var currentColorSetting:String = bind (colorSettingSelectBox.selectedItem as SelectBoxItem).value.toString() on replace {
        //when select box changes, update colorPicker.color to stored setting
        currentColorStr = settings.get(currentColorSetting).toString();
        colorPicker.color = Color.web(currentColorStr);
        currentColor = colorPicker.color;
    }

    def taskSortSelectBox:SelectBox = SelectBox {
        options: [
            SelectBoxItem { text: 'Due & Priority', value: 'smart' }
            SelectBoxItem { text: 'Due Date', value: 'due' }
            SelectBoxItem { text: 'Priority', value: 'priority' }
            SelectBoxItem { text: 'Task Name', value: 'name' }
        ]
        layoutInfo: LayoutInfo { width: 80, height: 26 }
    }
    var taskSort:String = bind (taskSortSelectBox.selectedItem as SelectBoxItem).value.toString() on replace {
        var taskSortString = (taskSortSelectBox.selectedItem as SelectBoxItem).value.toString();
        if (taskSortString != null and taskSortString != "") {
            taskSortType = taskSortString;
        }
    }

    def resetDefaultButton:Button = Button {
        text: "Reset to defaults"
        action: resetAction
    }

    def logoutButton:Button = Button {
        text: "Logout of Cheqlist"
        action: logoutAction
        effect: ColorAdjust {
            hue: 0.0, saturation: 0.6
        }
    }

    override public function create():Node {
        toaster.hide();
        syncIntervalSelectBox.selectByValue(syncIntervalMillis.toString());
        taskSortSelectBox.selectByValue(taskSortType);
        colorSettingSelectBox.select(0);
        colorsInitialized = true;
        title = "Settings";
        return Group {
            content: [
                background, panelTitle, backButton,
                XMigLayout {
                    translateX: 9, translateY: 50
                    width: theme.paneWidth - 18, height: theme.paneHeight - 60,
                    id: 'settingsForm',
                    constraints: "fill, wrap",
                    rows: "[]1mm[]1mm[]1mm[]1mm[]1mm[]1mm[]1mm[]1mm[]1mm[]1mm[]push[]2mm[]", columns: "[]2mm[]",
                    content: [
                        migNode(colorPicker, "ax right"), migNode(colorSettingSelectBox, "ax left"),
                        migNode(showTooltipsCheckbox, "ax right, gapx 40px 0px"), migNode(createLabel("Show tooltips"), "ax left"),
                        //migNode(createLabel("Show completed tasks"), "ax right"), migNode(showCompletedCheckbox, "ax left"),
                        migNode(syncIntervalSelectBox, "ax right"), migNode(createLabel("Between RTM syncs"), "ax left"),
                        migNode(taskSortSelectBox, "ax right"), migNode(createLabel("To sort tasks"), "ax left"),
                        migNode(resetDefaultButton, "sx, growx"),
                        migNode(logoutButton, "sx, growx")
                    ]
                },
                toaster
            ]
        }
    }
}
