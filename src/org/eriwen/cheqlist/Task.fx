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
import javafx.scene.control.CheckBox;
import javafx.scene.control.Label;
import javafx.scene.effect.Effect;
import javafx.scene.effect.Glow;
import javafx.scene.input.MouseEvent;
import javafx.scene.shape.Rectangle;
import javafx.scene.text.Text;

import org.eriwen.cheqlist.theme.Theme;

/**
 * View pane for a task to be displayed in the TaskListPane. Must be initialized
 * with a theme, priority, due date, name, overdue, completeTaskAction, and
 * editTaskAction.
 *
 * @author Eric Wendelin
 */

public class Task extends CustomNode {
    public-init var theme:Theme;
    public-init var taskHeight:Number;
    public-init var priority:String;
    public-init var name:String;
    public-init var due:String;
    public-init var listName:String;
    public-init var tags:String;
    public-init var overdue:Boolean;
    public-init var completeTaskAction:function(e:MouseEvent);
    public-init var editTaskAction:function(e:MouseEvent);

    var currentEffect:Effect = Glow { level: 0.0 };
    def hoverEffect = Glow { level: 0.5 }

    def background: Rectangle = Rectangle {
        cursor: Cursor.HAND
        width: theme.paneWidth, height: taskHeight
        effect: bind currentEffect
        onMouseClicked: editTaskAction
        onMouseEntered: function(e:MouseEvent) {
            currentEffect = hoverEffect
        }
        onMouseExited: function(e:MouseEvent) {
            currentEffect = Glow { level: 0.0 }
        }
        fill: bind theme.backgroundColor
    }
    def taskPriority:Rectangle = Rectangle {
        width: 11, height: taskHeight,
        fill: bind if (priority.equals('1')) then theme.priority1Color
            else if (priority.equals('2')) then theme.priority2Color
            else if (priority.equals('3')) then theme.priority3Color
            else theme.priorityNColor
        effect: bind currentEffect
    }
    def checkbox:CheckBox = CheckBox {
        translateX: 17, translateY: 5,
        allowTriState: false, selected: false, blocksMouse: true,
        onMouseClicked: completeTaskAction
    }
    def taskDue:Text = Text {
        var maxWidth = 60;
        font: theme.detailFont
        fill: bind if (overdue) then theme.overdueTextColor else theme.dueDateTextColor
        x: theme.paneWidth - maxWidth, y: 14
        //Align right
        translateX: bind maxWidth - taskDue.boundsInLocal.width - 7
        content: due
    }
    def taskName:Label = Label {
        translateX: 38
        font: theme.normalFont, text: name,
        textFill: bind theme.foregroundColor
        width: theme.paneWidth - 100
    }
    def tagsLabel:Label = Label {
        translateX: 38, translateY: 16
        font: theme.detailFont, 
        text: if (tags != '') then "{listName}, {tags}"
                else listName
        textFill: bind theme.dueDateTextColor
        width: theme.paneWidth - 100
    }

    override public function create():Node {
        return Group {
            content: [background, taskPriority, taskDue, taskName, tagsLabel, checkbox]
        }
    }
}
