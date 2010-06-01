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
import javafx.scene.image.Image;
import javafx.scene.input.MouseEvent;
import javafx.scene.shape.Rectangle;
import org.eriwen.cheqlist.theme.Theme;
import org.eriwen.cheqlist.util.ViewUtils;

/**
 * @author Eric Wendelin
 */
public class Thinbar extends CustomNode {
    public-init var theme:Theme;
    public-init var mouseDraggedAction:function(MouseEvent);
    public-init var mouseReleasedAction:function(MouseEvent);
    public-init var viewUtils:ViewUtils;
    public-init var addTaskPane:Pane;
    public-init var taskListPane:Pane;
    public-init var listsListPane:Pane;
    public-init var settingsPane:Pane;
    package var showButtons:Boolean = false;
    package var showTooltips:Boolean;

    def thinbarButtons:ThinbarButton[] = [
        ThinbarButton {
            image: Image { url: theme.addImageUrl };
            translateY: 2
            viewUtils: viewUtils
            pane: addTaskPane
            tooltip: "AddTask"
            visible: bind showButtons
            showTooltip: bind showTooltips
            theme: theme
        }
        ThinbarButton {
            image: Image { url: theme.tasksImageUrl };
            translateY: 66
            viewUtils: viewUtils
            pane: taskListPane
            tooltip: " Tasks"
            visible: bind showButtons
            showTooltip: bind showTooltips
            theme: theme
        }
        ThinbarButton {
            image: Image { url: theme.listsImageUrl };
            translateY: 98
            viewUtils: viewUtils
            pane: listsListPane
            tooltip: " Lists"
            visible: bind showButtons
            showTooltip: bind showTooltips
            theme: theme
        }
        ThinbarButton {
            image: Image { url: theme.settingsImageUrl };
            translateY: theme.stageHeight - 100
            viewUtils: viewUtils
            pane: settingsPane
            tooltip: "Settings"
            visible: bind showButtons
            showTooltip: bind showTooltips
            theme: theme
        }
        ThinbarButton {
            image: Image { url: theme.logoutImageUrl };
            translateY: theme.stageHeight - 36
            viewUtils: viewUtils
            pane: settingsPane
            tooltip: "  Exit"
            visible: true
            showTooltip: bind showTooltips
            theme: theme
            onMouseClicked: function(e) {
                FX.exit();
            }
        }
    ];

    public override function create():Node {
        return Group {
            var back:Rectangle = Rectangle {
                height: theme.thinbarHeight, width: theme.thinbarWidth,
                cursor: Cursor.MOVE,
                fill: bind theme.backgroundColor
                onMouseDragged: mouseDraggedAction,
                onMouseReleased: mouseReleasedAction
            }
            content: bind [back, thinbarButtons]
        }
    }
}
