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

import javafx.scene.*;
import javafx.scene.control.*;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.layout.VBox;

import org.jfxtras.scene.layout.XMigLayout;
import org.jfxtras.scene.layout.XMigLayout.*;

import org.eriwen.cheqlist.control.SelectBoxItem;
import org.eriwen.cheqlist.util.GroovyRtmUtils;
import org.eriwen.rtm.RtmService;

/**
 * View for the Add Task form.
 *
 * @author <a href="http://eriwen.com">Eric Wendelin</a>
 */
package class AddTaskPane extends TaskPaneBase {
    public-init var updateTaskListAction:function();
    public-init var addTaskAction:function();
    public-init var rtm:RtmService;
    public-init var rtmUtils:GroovyRtmUtils;

    def nameField = createTextField("fieldName");
    def dueField = createTextField("fieldDue");
    def repeatField = createTextField("fieldRepeat");
    def estimateField = createTextField("fieldEstimate");
    def tagsField = createTextField("fieldTags");
    def urlField = createTextField("fieldURL");

    def noteTextBox:TextBox = TextBox {
        multiline: true, selectOnFocus: true, columns: 26, lines: 3
    }

    def addTaskButton:Button = Button { 
        text: "Add Task", action: addTask
        layoutInfo: LayoutInfo { width: theme.paneWidth - 18 }
    }
    def clearButton:Button = Button { 
        text: "Clear", action: resetForm
        layoutInfo: LayoutInfo { width: theme.paneWidth - 18 }
    }
    def bottomButtons:VBox = VBox {
        translateX: 9, translateY: theme.paneHeight - 60
        spacing: 5
        content: [addTaskButton, clearButton]
    }

    function resetForm():Void {
        nameField.clear();
        dueField.clear();
        estimateField.clear();
        repeatField.clear();
        tagsField.clear();
        urlField.clear();
        prioritySelectBox.select(0);
        listsSelectBox.select(0);
        locationsSelectBox.select(0);
        noteTextBox.clear();
    }

    function addTask():Void {
        if (not nameField.text.equals('')) {
            toaster.show('Adding Task...');
            var newTask:Map;
            rtmUtils.asyncTask(function () {
                newTask = rtm.tasksAdd(nameField.text,
                        (prioritySelectBox.selectedItem as SelectBoxItem).value.toString(),
                        dueField.text, estimateField.text, repeatField.text, tagsField.text,
                        (locationsSelectBox.selectedItem as SelectBoxItem).value.toString(), urlField.text,
                        (listsSelectBox.selectedItem as SelectBoxItem).value.toString());
            }, function (result):Void {
                if (result != null) {
                    if (not noteTextBox.text.equals('')) {
                        rtm.tasksNotesAdd(newTask.get('list_id').toString(),
                        newTask.get('taskseries_id').toString(),
                        newTask.get('task_id').toString(), 'Note1', noteTextBox.text);
                    }

                    nameField.requestFocus();
                    toaster.showTimed('"{nameField.text}" added!', 2s);
                    resetForm();
                    updateTaskListAction();
                }
            }, showToasterError);
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
                    width: theme.paneWidth - 18, height: theme.paneHeight - 80
                    id: 'addTaskForm'
                    constraints: "fill, wrap"
                    rows: "[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]2mm[]6mm[]"
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
                        migNode(createLabel("Note:"), "ax right"), migNode(noteTextBox, "growx")
                    ]
                },
                bottomButtons,
                toaster
            ]
        }
    }
}
