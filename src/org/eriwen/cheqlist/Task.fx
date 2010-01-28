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
package org.eriwen.cheqlist;

import javafx.scene.*;
import javafx.scene.control.CheckBox;
import javafx.scene.control.Label;
import javafx.scene.effect.Effect;
import javafx.scene.effect.Glow;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.*;
import javafx.scene.shape.Rectangle;
import javafx.scene.text.TextAlignment;
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

    def background = Rectangle {
        var stopColor = bind if (priority.equals('1')) then theme.priority1Color
            else if (priority.equals('2')) then theme.priority2Color
            else if (priority.equals('3')) then theme.priority3Color
            else theme.priorityNColor;
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
        fill: LinearGradient {
            startX: 0.1, startY: 0.0
            endX: 0.7, endY: 0.4
            stops: [
                Stop { color: stopColor, offset: 0.0 },
                Stop { color: theme.backgroundColor, offset: 0.5 }
            ]
        }
    }

    def taskDue:Text = Text {
        var wrappingWidth = 60;
        font: theme.detailFont
        fill: bind if (overdue) then theme.overdueTextColor else theme.dueDateTextColor
        x: theme.paneWidth - wrappingWidth, y: 14
        //Align right
        wrappingWidth: wrappingWidth, translateX: bind wrappingWidth - taskDue.boundsInLocal.width - 7, textAlignment: TextAlignment.RIGHT
        content: due
    }
    def taskName = Label {
        translateX: 28
        font: theme.normalFont, text: name,
        textFill: bind theme.foregroundColor
        width: theme.paneWidth - 90
    }
    def tagsLabel = Label {
        translateX: 28, translateY: 16
        font: theme.detailFont, 
        text: if (tags != '') then "{listName}, {tags}"
                else listName
        textFill: bind theme.dueDateTextColor
        width: theme.paneWidth - 90
    }

    def checkbox = CheckBox {
        translateX: 7, translateY: 2,
        allowTriState: false, selected: false, blocksMouse: true,
        onMouseClicked: completeTaskAction
    }

    override public function create():Node {
        return Group {
            content: [background, taskDue, taskName, tagsLabel, checkbox]
        }
    }
}
