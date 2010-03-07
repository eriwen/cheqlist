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
import javafx.scene.effect.ColorAdjust;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.LayoutInfo;

import org.jfxtras.scene.layout.MigLayout;
import org.jfxtras.scene.layout.MigLayout.*;

import org.eriwen.rtm.RtmService;
import org.eriwen.cheqlist.control.LiveEditTextBox;
import org.eriwen.cheqlist.control.SelectBox;
import org.eriwen.cheqlist.control.SelectBoxItem;
import org.eriwen.cheqlist.util.GroovyRtmUtils;
import org.eriwen.cheqlist.util.StringUtils;

/**
 * The pane for editing a task. Must be initialized with a task
 *
 * @author Eric Wendelin
 */

package class EditTaskPane extends Pane {
    public-init var timezoneOffset:Integer;
    public-init var rtm:RtmService;
    public-init var rtmUtils:GroovyRtmUtils;
    public-init var strUtils:StringUtils;
    
    package var task:LinkedHashMap on replace {
        taskId = task.get('task_id').toString();
        taskSeriesId = task.get('taskseries_id').toString();
        listId = task.get('list_id').toString();
        nameField.text = task.get('name').toString();
        dueField.text = strUtils.formatFriendlyDate(task.get('due').toString(), task.get('has_due_time').toString(), timezoneOffset);
        repeatField.text = strUtils.formatFriendlyRepeat(task.get('repeat').toString());
        estimateField.text = task.get('estimate').toString();
        tagsField.text = task.get('tags').toString();
        urlField.text = task.get('url').toString();
        listsSelectBox.selectByValue(task.get('list_id').toString());
        locationsSelectBox.selectByValue(task.get('location_id').toString());
        prioritySelectBox.selectByValue(task.get('priority').toString());
    };
    package var taskId:String;
    package var taskSeriesId:String;
    package var listId:String;
    package var updateTaskListAction:function();
    var initialized = false;

    package var lists:List on replace {
        //Add options to List combo box
        delete listsSelectBox.options;
        insert SelectBoxItem { text: '', value: '' } into listsSelectBox.options;
        for (list in lists) {
            var listMap:LinkedHashMap = list as LinkedHashMap;
            //Do not add smart lists or archived to options
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
            var locMap:LinkedHashMap = loc as LinkedHashMap;
            var item = SelectBoxItem {
                text: locMap.get('name') as String
                value: locMap.get('id') as String
            }
            insert item into locationsSelectBox.options
        }
        locationsSelectBox.select(0);
    };

    init {
        prioritySelectBox.select(0);
        initialized = true;
    }

    def nameField = createTextField(onNameChanged);
    def dueField = createTextField(onDueChanged);
    def repeatField = createTextField(onRepeatChanged);
    def estimateField = createTextField(onEstimateChanged);
    def tagsField = createTextField(onTagsChanged);
    def urlField = createTextField(onUrlChanged);
    def prioritySelectBox:SelectBox = SelectBox {
        options: [
            SelectBoxItem { text: 'None', value: 'N' }
            SelectBoxItem { text: 'Low', value: '3' }
            SelectBoxItem { text: 'Medium', value: '2' }
            SelectBoxItem { text: 'High', value: '1' }
        ]
        layoutInfo: LayoutInfo { width: 150, height: 26 }
    }
    def priority:String = bind (prioritySelectBox.selectedItem as SelectBoxItem).value.toString() on replace {
        if (initialized) {
            if((prioritySelectBox.selectedItem as SelectBoxItem).value.toString() != task.get('priority').toString()) {
                rtmUtils.asyncTask(function () {
                    rtm.tasksSetPriority(listId, taskSeriesId, taskId, (prioritySelectBox.selectedItem as SelectBoxItem).value.toString());
                    updateTaskListAction();
                    }, function (result):Void {}, function (e:ExecutionException):Void {
                        toaster.showTimed(e.getCause().getMessage());
                    }
                );
            }
        }
    }

    def listsSelectBox:SelectBox = SelectBox {
        layoutInfo: LayoutInfo { width: 150, height: 26 }
        options: []
        blocksMouse: true
    }
    def list:String = bind (listsSelectBox.selectedItem as SelectBoxItem).value.toString() on replace {
        if((listsSelectBox.selectedItem as SelectBoxItem).value.toString() != task.get('list_id').toString()) {
            rtmUtils.asyncTask(function () {
                rtm.tasksMoveTo(listId, taskSeriesId, taskId, (listsSelectBox.selectedItem as SelectBoxItem).value.toString());
                updateTaskListAction();
                }, function (result):Void {}, function (e:ExecutionException):Void {
                    toaster.showTimed(e.getCause().getMessage());
                }
            );
        }
    }

    def locationsSelectBox:SelectBox = SelectBox {
        layoutInfo: LayoutInfo { width: 150, height: 26 }
        options: []
        blocksMouse: true
    }
    def location:String = bind (locationsSelectBox.selectedItem as SelectBoxItem).value.toString() on replace {
        if((locationsSelectBox.selectedItem as SelectBoxItem).value.toString() != task.get('location_id').toString()) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetLocation(listId, taskSeriesId, taskId, (locationsSelectBox.selectedItem as SelectBoxItem).value.toString());
                }, function (result):Void {}, function (e:ExecutionException):Void {
                    toaster.showTimed(e.getCause().getMessage());
                }
            );
        }
    }

    def completeTaskButton:Button = Button {
        text: "Complete Task",
        action: completeTask
    }
    def postponeTaskButton:Button = Button {
        text: "Postpone Task",
        action: postponeTask
    }
    def deleteTaskButton:Button = Button {
        text: "Delete Task"
        action: deleteTask
        effect: ColorAdjust {
            hue: 0.0, saturation: 0.6
        }
    }

    function createLabel(text:String) {
        Label { 
            width: 80, height: 26
            text: text, textFill: bind theme.foregroundColor
        }
    }
    function createTextField(onchanged:function(String)) {
        LiveEditTextBox { 
            selectOnFocus: true
            blocksMouse: true
            columns: 22
            onChange: onchanged
        }
    }

    function onNameChanged(value:String) {
        if (value != task.get('name').toString()) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetName(listId, taskSeriesId, taskId, value);
                updateTaskListAction();
                }, function (result):Void {}, function (e:ExecutionException):Void {
                    toaster.show(e.getCause().getMessage());
                }
            );
        }
    }
    function onDueChanged(value:String) {
        if(value != strUtils.formatFriendlyDate(task.get('due').toString(), task.get('has_due_time').toString(), timezoneOffset)) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetDueDate(listId, taskSeriesId, taskId, value, true, true);
                updateTaskListAction();
                }, function (result):Void {}, function (e:ExecutionException):Void {
                    toaster.show(e.getCause().getMessage());
                }
            );
        }
    }
    function onRepeatChanged(value:String) {
        if(value != strUtils.formatFriendlyRepeat(task.get('repeat').toString())) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetRecurrence(listId, taskSeriesId, taskId, value);
                }, function (result):Void {}, function (e:ExecutionException):Void {
                    toaster.show(e.getCause().getMessage());
                }
            );
        }
    }
    function onEstimateChanged(value:String) {
        if (value != task.get('estimate').toString()) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetEstimate(listId, taskSeriesId, taskId, value);
                }, function (result):Void {}, function (e:ExecutionException):Void {
                    toaster.show(e.getCause().getMessage());
                }
            );
        }
    }
    function onTagsChanged(value:String) {
        if(value != task.get('tags').toString()) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetTags(listId, taskSeriesId, taskId, value);
                updateTaskListAction();
                }, function (result):Void {}, function (e:ExecutionException):Void {
                    toaster.show(e.getCause().getMessage());
                }
            );
        }
    }
    function onUrlChanged(value:String) {
        if(value != task.get('url').toString()) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetUrl(listId, taskSeriesId, taskId, value);
                }, function (result):Void {}, function (e:ExecutionException):Void {
                    toaster.show(e.getCause().getMessage());
                }
            );
        }
    }

    function completeTask():Void {
        toaster.showTimed('Completing "{nameField.text}"...', 5s);
        rtmUtils.asyncTask(function () {
                rtm.tasksComplete(listId, taskSeriesId, taskId);
                updateTaskListAction();
            }, function (result):Void {
                closeAction(new MouseEvent());
            }, function (e:ExecutionException):Void {
                toaster.show(e.getCause().getMessage());
            }
        );
    }

    function postponeTask():Void {
        toaster.showTimed('Postponing "{nameField.text}"...', 5s);
        rtmUtils.asyncTask(function () {
                rtm.tasksPostpone(listId, taskSeriesId, taskId);
                updateTaskListAction();
            }, function (result):Void {
                closeAction(new MouseEvent());
            }, function (e:ExecutionException):Void {
                toaster.show(e.getCause().getMessage());
            }
        );
    }

    function deleteTask():Void {
        toaster.showTimed('Deleting "{nameField.text}"...', 5s);
        rtmUtils.asyncTask(function () {
                rtm.tasksDelete(listId, taskSeriesId, taskId);
                updateTaskListAction();
            }, function (result):Void {
                closeAction(new MouseEvent());
            }, function (e:ExecutionException):Void {
                toaster.showTimed(e.getCause().getMessage());
            }
        );
    }

    override public function create():Node {
        toaster.hide();
        title = "Edit Task";
        return Group {
            content: [
                background, panelTitle, backButton,
                MigLayout {
                    translateX: 9, translateY: 30
                    width: theme.paneWidth - 18, height: theme.paneHeight - 40
                    id: 'editTaskForm'
                    constraints: "fill, wrap"
                    rows: "[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]4mm[]2mm[]2mm[]"
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
                        migNode(completeTaskButton, "sx, growx"),
                        migNode(postponeTaskButton, "sx, growx"),
                        migNode(deleteTaskButton, "sx, growx")
                    ]
                },
                toaster
            ]
        }
    }
}
