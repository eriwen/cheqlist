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
import javafx.animation.*;
import javafx.geometry.HPos;
import javafx.geometry.VPos;
import javafx.scene.*;
import javafx.scene.control.TextBox;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.*;
import javafx.scene.shape.Rectangle;

import org.eriwen.cheqlist.util.*;
import org.eriwen.rtm.RtmService;

/**
 * Pane containing the task list and some related operations. Must be initialized
 * with a taskList, rtmService, and editAction (that opens the EditTaskPane)
 *
 * @author Eric Wendelin
 */

package class TaskListPane extends Pane {

    package var taskList = [];
    def taskHeight:Number = 30.0;
    package var timezoneOffset:Integer;
    package var taskFilter:String;
    //var taskComparator:Comparator;
    package var taskSortType:String on replace {
        if (tasks != null) {
            sortTasks();
        }
    };
    package var lists:List;
    public-init var editAction:function(task:LinkedHashMap);
    public-init var updateTaskListAction:function(String);
    public-init var rtm:RtmService;
    public-init var rtmUtils:GroovyRtmUtils;
    public-init var strUtils:StringUtils;
    def fadeoutScrollOpacity = 0.3;
    def fadeinScrollOpacity = 0.8;

    function getListNameById(listId:String):String {
        for (list in lists) {
           var listMap:Map = list as LinkedHashMap;
           if (listMap.get('id').toString() == listId) {
               return listMap.get('name').toString();
           }
        }
        return '';
    }

    public function sortTasks():Void {
        if (taskSortType.equals('name')) {
            Collections.sort(tasks, rtmUtils.nameComparator);
        } else if (taskSortType.equals('due')) {
            Collections.sort(tasks, rtmUtils.dueDateComparator);
        } else if (taskSortType.equals('priority')) {
            Collections.sort(tasks, rtmUtils.priorityComparator);
        } else {
            Collections.sort(tasks, rtmUtils.smartComparator);
        }
        delete taskList;
        for (task in tasks) {
            var taskMap = task as LinkedHashMap;
            insert taskMap into taskList;
        }
    }

    package var tasks:List on replace {
        scrollIndicatorY = 0.0;
        scrollY = 0.0;
        sortTasks();
    };

    override var focusTraversable = true;

    public def taskFilterBox:TextBox = TextBox {
        translateY: 3
        layoutInfo: LayoutInfo { width: theme.paneWidth - 64, height: 24 }
        focusTraversable: false, selectOnFocus: false
        promptText: 'Search'
        text: taskFilter
        action: function () {
            taskFilter = taskFilterBox.text;
            toaster.showTimed('Searching tasks...');
            updateTaskListAction(taskFilterBox.text)
        }
    }

    public def searchButton:ImageView = ImageView {
        image: Image { url: theme.searchImageUrl },
        translateX: theme.paneWidth - 90, translateY: 4,
        cursor: Cursor.HAND,
        onMouseReleased: function (e:MouseEvent) {
            //Set rawText to text in the TextBox
            taskFilterBox.commit();
            taskFilterBox.action();
        }
    }

    def searchForm = Group {
        translateX: 15, translateY: 6
        content: [taskFilterBox, searchButton]
    }

    def taskListContainer:VBox = VBox {
        translateX: 0, translateY: 40
        spacing: 1
        width: theme.paneWidth, height: theme.paneHeight - 174,
        focusTraversable: false
        content: bind for (task in taskList) {
            var taskMap = task as LinkedHashMap;
            var dueStr = taskMap.get('due').toString();
            var taskName = taskMap.get('name').toString();
            Task {
                taskHeight: taskHeight
                name: taskName
                due: strUtils.formatFriendlyDate(dueStr, taskMap.get('has_due_time').toString(), timezoneOffset)
                listName: getListNameById(taskMap.get('list_id').toString())
                tags: taskMap.get('tags').toString()
                overdue: strUtils.isOverdue(dueStr, timezoneOffset);
                priority: taskMap.get('priority').toString()
                theme: theme
                completeTaskAction: function (e:MouseEvent) {
                    toaster.showTimed('Completing "{taskName}"...', 60s);
                    rtmUtils.asyncTask(function () {
                        rtm.tasksComplete(taskMap.get('list_id').toString(),
                                taskMap.get('taskseries_id').toString(), taskMap.get('task_id').toString());
                    }, function (result):Void {
                        if (result != null) {
                            delete task from taskList;
                            toaster.showTimed('"{taskName}" completed', 1.5s);
                            //Set focus to prevent taskFilterBox contents from erasure
                            quickAddTextBox.requestFocus();
                            updateTaskListAction(taskFilterBox.text);
                        }
                    }, function (e:ExecutionException):Void {
                        toaster.showTimed(e.getCause().getMessage());
                    });
                }
                editTaskAction: function (e:MouseEvent) {
                    editAction(taskMap);
                }
            }
        }
    }

    var scrollY:Number = 0.0 on replace {
        taskListClipView.clipY = scrollY;
    };
    def totalHeight = bind (taskHeight + 1.0) * (sizeof taskList + 1.0);
    def clipHeight = 415.0;

    def taskListClipView:ClipView = ClipView {
        clipX: 0.0, clipY: 0.0
        node: taskListContainer
        pannable: false
        layoutInfo: LayoutInfo {
            width: theme.paneWidth, height: clipHeight
        }
        onMouseWheelMoved: function(e:MouseEvent):Void {
            if ((scrollY <= 0 and e.wheelRotation < 0) or
                    (scrollY >= (totalHeight - clipHeight) and e.wheelRotation > 0)) {
                return;
            } else {
                scrollY += e.wheelRotation * (taskHeight + 1.0);
                scrollIndicatorOpacity = fadeinScrollOpacity;
                //FIXME: do different math here
                scrollIndicatorY = 45 + scrollY * 0.7 * (clipHeight / totalHeight);
                (Timeline {
                    keyFrames: [
                        KeyFrame { time: 0.4s,
                            values: scrollIndicatorOpacity => fadeinScrollOpacity tween Interpolator.EASEIN
                        }
                        KeyFrame { time: 0.8s,
                            values: scrollIndicatorOpacity => fadeoutScrollOpacity tween Interpolator.EASEOUT
                        }
                    ]
                }).play();
            }
        }
    }

    var scrollIndicatorOpacity:Number = fadeoutScrollOpacity;
    var scrollIndicatorY:Number = 0.0;
    var scrollIndicatorHeight:Number = bind clipHeight * (clipHeight / totalHeight);
    var scrollIndicator:Rectangle = Rectangle {
        translateX: theme.paneWidth - 6, translateY: bind scrollIndicatorY
        arcHeight: 5, arcWidth: 5
        width: 4, height: bind scrollIndicatorHeight
        fill: bind theme.foregroundColor
        opacity: bind scrollIndicatorOpacity
        visible: bind if (totalHeight > clipHeight) then true else false
        onMouseEntered: function(e:MouseEvent):Void {
            (Timeline {
                keyFrames: [
                    KeyFrame { time: 0.1s,
                        values: scrollIndicatorOpacity => fadeinScrollOpacity tween Interpolator.EASEIN
                    }
                ]
            }).play();
        }
        onMouseExited: function(e:MouseEvent):Void {
            (Timeline {
                keyFrames: [
                    KeyFrame { time: 0.4s,
                        values: scrollIndicatorOpacity => fadeoutScrollOpacity tween Interpolator.EASEIN
                    }
                ]
            }).play();
        }
        /*onMouseDragged: function(e:MouseEvent):Void {
            var yChange = e.screenY - e.dragAnchorY;
            if ((scrollY <= 0 and yChange < 0) or
                    (scrollY >= (totalHeight - clipHeight) and yChange > 0)) {
                return;
            } else {
                scrollY += yChange;
            }
        }*/
    }

    function quickAddAction(e:MouseEvent):Void {
        toaster.show("Adding task...");
        rtmUtils.asyncTask(function () {
            rtm.tasksAdd(quickAddTextBox.rawText, null, true);
        }, function (result):Void {
            if (result != null) {
                toaster.showTimed('"{quickAddTextBox.rawText}" added!', 1.5s);
                updateTaskListAction(taskFilterBox.text);
                quickAddTextBox.text = '';
            }
        }, function (e:ExecutionException):Void {
            toaster.showTimed(e.getCause().getMessage());
        });
    }

    def quickAddTextBox:TextBox = TextBox {
        columns: 20, selectOnFocus: true,
        promptText: "Smart Add"
        layoutInfo: LayoutInfo { width: theme.paneWidth - 23, height: 24 }
        action: function () { quickAddAction(new MouseEvent()) }
    };

    def quickAdd = Group {
        var quickAddForm:HBox;
        var quickAddHeight = 29;
        translateY: theme.paneHeight - quickAddHeight
        blocksMouse: true
        content: [
            Rectangle {
                width: theme.paneWidth, height: quickAddHeight
                fill: bind theme.backgroundColor
            }
            quickAddForm = HBox {
                translateX: 15, spacing: 5,
                hpos: HPos.CENTER, vpos: VPos.CENTER, nodeVPos: VPos.BOTTOM
                content: [quickAddTextBox]
            }
        ]
    }

    def searchGroup:Group = Group {
        blocksMouse: true
        content: [
            Rectangle {
                height: 40, width: theme.paneWidth
                fill: bind theme.backgroundColor
            },
            searchForm, backButton
        ]
    }

    public override function create():Node {
        toaster.hide();
        return Group {
            content: [
                background, 
                VBox { content: [taskListClipView] },
                scrollIndicator,
                searchGroup, quickAdd, toaster
            ]
        }
    }
}
