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
import javafx.scene.layout.VBox;

import org.jfxtras.scene.layout.XMigLayout;
import org.jfxtras.scene.layout.XMigLayout.*;

import org.eriwen.rtm.RtmService;
import org.eriwen.cheqlist.control.LiveEditTextBox;
import org.eriwen.cheqlist.control.SelectBoxItem;
import org.eriwen.cheqlist.util.GroovyRtmUtils;
import org.eriwen.cheqlist.util.StringUtils;

/**
 * The pane for editing a task. Must be initialized with a task
 *
 * @author <a href="http://eriwen.com">Eric Wendelin</a>
 */
package class EditTaskPane extends TaskPaneBase {
    public-init var timezoneOffset:Integer;
    public-init var rtm:RtmService;
    public-init var rtmUtils:GroovyRtmUtils;
    public-init var strUtils:StringUtils;
    
    package var task:LinkedHashMap on replace {
        taskId = task.get('task_id').toString();
        taskSeriesId = task.get('taskseries_id').toString();
        listId = task.get('list_id').toString();
        nameField.text = new String((task.get('name').toString()).getBytes(), 'UTF-8');
        dueField.text = strUtils.formatFriendlyDate(task.get('due').toString(), task.get('has_due_time').toString(), timezoneOffset);
        repeatField.text = strUtils.formatFriendlyRepeat(task.get('repeat').toString());
        estimateField.text = task.get('estimate').toString();
        tagsField.text = new String((task.get('tags').toString()).getBytes(), 'UTF-8');
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

    def priority:String = bind (prioritySelectBox.selectedItem as SelectBoxItem).value.toString() on replace {
        if (initialized) {
            if((prioritySelectBox.selectedItem as SelectBoxItem).value.toString() != task.get('priority').toString()) {
                rtmUtils.asyncTask(function () {
                    rtm.tasksSetPriority(listId, taskSeriesId, taskId,
                            (prioritySelectBox.selectedItem as SelectBoxItem).value.toString());
                    updateTaskListAction();
                    }, function (result):Void {}, showToasterError
                );
            }
        }
    }

    def list:String = bind (listsSelectBox.selectedItem as SelectBoxItem).value.toString() on replace {
        if((listsSelectBox.selectedItem as SelectBoxItem).value.toString() != task.get('list_id').toString()) {
            rtmUtils.asyncTask(function () {
                rtm.tasksMoveTo(listId, taskSeriesId, taskId, (listsSelectBox.selectedItem as SelectBoxItem).value.toString());
                updateTaskListAction();
                }, function (result):Void {}, showToasterError
            );
        }
    }

    def location:String = bind (locationsSelectBox.selectedItem as SelectBoxItem).value.toString() on replace {
        if((locationsSelectBox.selectedItem as SelectBoxItem).value.toString() != task.get('location_id').toString()) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetLocation(listId, taskSeriesId, taskId,
                    (locationsSelectBox.selectedItem as SelectBoxItem).value.toString());
                }, function (result):Void {}, showToasterError
            );
        }
    }

    def noteTextBox:TextBox = TextBox {
        multiline: true, selectOnFocus: true, columns: 26, lines: 3
    }
    def completeTaskButton:Button = Button {
        text: "Complete Task",
        action: completeTask
        layoutInfo: LayoutInfo { width: theme.paneWidth - 18 }
    }
    def postponeTaskButton:Button = Button {
        text: "Postpone Task",
        action: postponeTask
        layoutInfo: LayoutInfo { width: theme.paneWidth - 18 }
    }
    def deleteTaskButton:Button = Button {
        text: "Delete Task"
        action: deleteTask
        effect: ColorAdjust {
            hue: 0.0, saturation: 0.6
        }
        layoutInfo: LayoutInfo { width: theme.paneWidth - 18 }
    }

    def bottomButtons:VBox = VBox {
        translateX: 9, translateY: theme.paneHeight - 75
        spacing: 5
        content: [completeTaskButton, postponeTaskButton, deleteTaskButton]
    }

    function createTextField(onchanged:function(String)) {
        LiveEditTextBox { 
            selectOnFocus: true
            blocksMouse: true
            columns: 26
            onChange: onchanged
        }
    }

    function onNameChanged(value:String) {
        if (value != new String((task.get('name').toString()).getBytes(), 'UTF-8')) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetName(listId, taskSeriesId, taskId, value);
                updateTaskListAction();
                }, function (result):Void {}, showToasterError
            );
        }
    }
    function onDueChanged(value:String) {
        if(value != strUtils.formatFriendlyDate(task.get('due').toString(),
                task.get('has_due_time').toString(), timezoneOffset)) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetDueDate(listId, taskSeriesId, taskId, value, true, true);
                updateTaskListAction();
                }, function (result):Void {}, showToasterError
            );
        }
    }
    function onRepeatChanged(value:String) {
        if(value != strUtils.formatFriendlyRepeat(task.get('repeat').toString())) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetRecurrence(listId, taskSeriesId, taskId, value);
                }, function (result):Void {}, showToasterError
            );
        }
    }
    function onEstimateChanged(value:String) {
        if (value != task.get('estimate').toString()) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetEstimate(listId, taskSeriesId, taskId, value);
                }, function (result):Void {}, showToasterError
            );
        }
    }
    function onTagsChanged(value:String) {
        if(value != task.get('tags').toString()) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetTags(listId, taskSeriesId, taskId, value);
                updateTaskListAction();
                }, function (result):Void {}, showToasterError
            );
        }
    }
    function onUrlChanged(value:String) {
        if(value != task.get('url').toString()) {
            rtmUtils.asyncTask(function () {
                rtm.tasksSetUrl(listId, taskSeriesId, taskId, value);
                }, function (result):Void {}, showToasterError
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
            }, showToasterError
        );
    }

    function postponeTask():Void {
        toaster.showTimed('Postponing "{nameField.text}"...', 5s);
        rtmUtils.asyncTask(function () {
                rtm.tasksPostpone(listId, taskSeriesId, taskId);
                updateTaskListAction();
            }, function (result):Void {
                closeAction(new MouseEvent());
            }, showToasterError
        );
    }

    function deleteTask():Void {
        toaster.showTimed('Deleting "{nameField.text}"...', 5s);
        rtmUtils.asyncTask(function () {
                rtm.tasksDelete(listId, taskSeriesId, taskId);
                updateTaskListAction();
            }, function (result):Void {
                closeAction(new MouseEvent());
            }, showToasterError
        );
    }

    //TODO: show notes

    override public function create():Node {
        toaster.hide();
        title = "Edit Task";
        return Group {
            content: [
                background, panelTitle, backButton,
                XMigLayout {
                    translateX: 9, translateY: 30
                    width: theme.paneWidth - 18, height: theme.paneHeight - 100
                    id: 'editTaskForm'
                    constraints: "fill, wrap"
                    rows: "[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]"
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
                        migNode(createLabel("Location:"), "ax right"), migNode(locationsSelectBox, "growx")
//                        migNode(createLabel("Note:"), "ax right"), migNode(noteTextBox, "growx")
                    ]
                },
                bottomButtons,
                toaster
            ]
        }
    }
}
