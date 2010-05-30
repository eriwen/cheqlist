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

import java.util.*;
import java.util.concurrent.ExecutionException;

import javafx.scene.*;
import javafx.scene.control.*;
import javafx.scene.layout.LayoutInfo;

import org.jfxtras.scene.layout.XMigLayout;
import org.jfxtras.scene.layout.XMigLayout.*;

import org.eriwen.cheqlist.control.SelectBox;
import org.eriwen.cheqlist.control.SelectBoxItem;
import org.eriwen.cheqlist.util.GroovyRtmUtils;
import org.eriwen.rtm.RtmService;

/**
 * View for the Add Task form
 *
 * @author <a href="http://eriwen.com">Eric Wendelin</a>
 */

package class AddTaskPane extends Pane {
    public-init var updateTaskListAction:function();
    public-init var addTaskAction:function();
    public-init var rtm:RtmService;
    public-init var rtmUtils:GroovyRtmUtils;
    def selectBoxLayoutInfo = LayoutInfo { width: 170, height: 26 }

    package var lists:List on replace {
        //Add options to List combo box
        delete listsSelectBox.options;
        insert SelectBoxItem { text: '', value: '' } into listsSelectBox.options;
        for (list in lists) {
            var listMap:Map = list as LinkedHashMap;
            //Do not add smart lists to options
            if ((listMap.get('smart') as String).equals('0') and (listMap.get('archived') as String).equals('0')) {
                insert SelectBoxItem {
                    text: listMap.get('name') as String
                    value: listMap.get('id') as String
                } into listsSelectBox.options
            }
        }
        listsSelectBox.select(0);
    };
    package var locations:List on replace {
        //Add options for locations box
        insert SelectBoxItem { text: '', value: '' } into locationsSelectBox.options;
        for (loc in locations) {
            var locMap:Map = loc as LinkedHashMap;
            insert SelectBoxItem {
                text: locMap.get('name') as String
                value: locMap.get('id') as String
            } into locationsSelectBox.options
        }
        locationsSelectBox.select(0);
    };

    def nameField = createTextField("fieldName");
    def dueField = createTextField("fieldDue");
    def repeatField = createTextField("fieldRepeat");
    def estimateField = createTextField("fieldEstimate");
    def tagsField = createTextField("fieldTags");
    def urlField = createTextField("fieldURL");
    def prioritySelectBox = SelectBox {
        options: [
            SelectBoxItem { text: 'None', value: 'N' }
            SelectBoxItem { text: 'Low', value: '3' }
            SelectBoxItem { text: 'Medium', value: '2' }
            SelectBoxItem { text: 'High', value: '1' }
        ]
        layoutInfo: selectBoxLayoutInfo
    }
    def listsSelectBox = SelectBox {
        layoutInfo: selectBoxLayoutInfo
    }
    def locationsSelectBox = SelectBox {
        layoutInfo: selectBoxLayoutInfo
    }

    def addTaskButton:Button = Button { text: "Add Task", action: addTask }
    def clearButton:Button = Button { text: "Clear", action: resetForm }

    function createLabel(text:String) {
        Label { text: text, textFill: bind theme.foregroundColor, width: 80, height: 26 }
    }
    function createTextField(id:String) {
        TextBox { id: id, selectOnFocus: true, columns: 22 }
    }

    function resetForm():Void {
        nameField.text = '';
        dueField.text = '';
        estimateField.text = '';
        repeatField.text = '';
        tagsField.text = '';
        urlField.text = '';
        prioritySelectBox.select(0);
        listsSelectBox.select(0);
        locationsSelectBox.select(0);
    }

    function addTask():Void {
        if (not nameField.text.equals('')) {
            toaster.show('Adding Task...');
            rtmUtils.asyncTask(function () {
                var newTask:Map = rtm.tasksAdd(nameField.text,
                        (prioritySelectBox.selectedItem as SelectBoxItem).value.toString(),
                        dueField.text, estimateField.text, repeatField.text, tagsField.text,
                        (locationsSelectBox.selectedItem as SelectBoxItem).value.toString(), urlField.text,
                        (listsSelectBox.selectedItem as SelectBoxItem).value.toString());
            }, function (result):Void {
                if (result != null) {
                    nameField.requestFocus();
                    toaster.showTimed('"{nameField.text}" added!', 2s);
                    resetForm();
                    updateTaskListAction();
                }
            }, function (e:ExecutionException):Void {
                toaster.showTimed(e.getCause().getMessage());
            });
        } else {
            toaster.showTimed('Task name cannot be blank', 2s);
        }
    }

    override public function create():Node {
        prioritySelectBox.select(0);
        title = "Add Task";
        toaster.hide();
        return Group {
            content: [
                background, panelTitle, backButton,
                XMigLayout {
                    translateX: 9, translateY: 30
                    width: theme.paneWidth - 18, height: theme.paneHeight - 40
                    id: 'addTaskForm'
                    constraints: "fill, wrap"
                    rows: "[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]4mm[]"
                    columns: "[]2mm[]"
                    content: [
                        migNode(createLabel("Name:"), "ax right"), migNode(nameField, "growx"),
                        migNode(createLabel("Due:"), "ax right"), migNode(dueField, "growx"),
                        migNode(createLabel("List:"), "ax right"), migNode(listsSelectBox, "growx"),
                        migNode(createLabel("Priority:"), "ax right"), migNode(prioritySelectBox, "growx"),
                        migNode(createLabel("Repeat:"), "ax right"), migNode(repeatField, "growx"),
                        migNode(createLabel("Estimate:"), "ax right"), migNode(estimateField, "growx"),
                        migNode(createLabel("Tags:"), "ax right"), migNode(tagsField, "growx"),
                        migNode(createLabel("URL:"), "ax right"), migNode(urlField, "growx"),
                        migNode(createLabel("Location:"), "ax right"), migNode(locationsSelectBox, "growx"),
                        migNode(addTaskButton, "sx, growx")
                    ]
                },
                toaster
            ]
        }
    }
}
