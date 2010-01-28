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
package org.eriwen.cheqlist.control;

import javafx.scene.Group;
import javafx.scene.control.*;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.layout.HBox;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javafx.scene.text.Font;

/**
 * @author Eric Wendelin
 */

public class SelectBoxSkin extends Skin {

    override var behavior = SelectBoxBehavior{};

    var arrowButtonBackgroundColor = Color.web("#F0F0F0");
    var arrowButtonBorderColor = Color.BLACK;
    var arrowColor = Color.BLACK;
    var focusBorderColor = Color.web("#0093FF");
    var selectBoxBackgroundColor = Color.WHITE;
    var selectBoxBorderColor = Color.web("#444444");
    var buttonWidth = 20.0;
    var listY = 0.0;

    public var showPopup = false on replace {
        if (showPopup) {
            listY = (node.localToScene(node.layoutBounds).maxY) + 2;
            list.visible = true;
            listView.requestFocus();
        } else {
            listY = (node.localToScene(node.layoutBounds).maxY) - 100;
        } 
    }

    public-read var listView:ListView = ListView {
        translateY: bind listY
        items: bind (control as SelectBox).options
        onMouseClicked: function(e) {
            showPopup = false;
            //TODO: fire onchanged event or something
            control.requestFocus();
        }
        layoutInfo: LayoutInfo {
            width: bind control.width, height: 100
        }
    };

    public-read var list:HBox = HBox {
        visible: false
        content: [listView]
        blocksMouse: true
        clip: bind Rectangle {
            x: -2, y: bind node.localToScene(node.layoutBounds).maxY
            width: bind control.width + 10
            height: 104
        }
    };

    var listViewFocus = bind listView.focused on replace {
        if(not listViewFocus) {
            showPopup = false;
        }
    }

    var listVisible = bind list.visible on replace {
        if(not listVisible) {
            delete list from list.scene.content;
        }
    }

    var text:Label = Label {
        font : Font { size : 12 }
        text: bind "{listView.selectedItem}"
        width: bind control.width - buttonWidth - 8
        layoutX: 8, layoutY: bind (control.height - text.layoutBounds.height)/2.0
    }

    var buttonBGRect:Rectangle = Rectangle {
        x: bind borderBGRect.width - buttonWidth, y: 4
        width: buttonWidth, height: bind borderBGRect.height - 2
        arcWidth: 5, arcHeight: 5
        fill: arrowButtonBackgroundColor
    }

    var borderLine = Line {
        startX: bind buttonBGRect.x + 1, startY: 2
        endX: bind buttonBGRect.x + 1, endY: bind buttonBGRect.height + 1
        strokeWidth: 1.0, stroke: arrowButtonBorderColor
    }

    var borderBGRect = Rectangle {
        x: 2, y: 2
        width: bind control.width - 2, height: bind control.height - 2
        arcWidth: 5, arcHeight: 5
        strokeWidth: 1.5, stroke: selectBoxBorderColor
        fill: selectBoxBackgroundColor
    }

    var focusRect = Rectangle {
        width: bind control.width + 3, height: bind control.height + 3
        arcWidth: 5, arcHeight: 5
        fill: bind if(control.focused or listView.focused) {
            focusBorderColor
        } else {
            Color.TRANSPARENT
        }
    }

    var arrow:Path = Path {
        layoutX: bind buttonBGRect.x + 4
        layoutY: bind (control.height - arrow.layoutBounds.height)/2.0 + 2
        elements: [
            MoveTo { x: 4.0 y: 0.0 },
            LineTo { x: bind (buttonBGRect.width - 6)/2.0 y: 4.0 },
            LineTo { x: bind (buttonBGRect.width - 9) y: 0.0 }
        ]
        strokeWidth: 1.5, stroke: arrowColor
    };

    override function intersects(x, y, w, h):Boolean {
        return node.intersects(x, y, w, h);
    }

    override function contains(x, y):Boolean {
        return node.contains(x, y);
    }

    init {
        node = Group {
            content: [focusRect, borderBGRect, text, buttonBGRect, borderLine, arrow]
            focusTraversable: false
        }

        node.onMousePressed = function(e) {
            var x = e.sceneX - e.x;
            var y = e.sceneY - e.y + node.layoutBounds.height;
            var visible = not showPopup;
            show(x, y, visible);
        }

        //Redirect key events on ListView to Control
        listView.onKeyPressed = function(e) {
            if(e.code == KeyCode.VK_ENTER) {
                list.visible = false;
                control.requestFocus();
            } else if(e.code == KeyCode.VK_ESCAPE) {
                show(0, 0, false);
            } else if(not ((e.code == KeyCode.VK_UP) or (e.code == KeyCode.VK_DOWN))) {
                control.onKeyPressed(e);
            }
        }
        listView.onKeyReleased = function(e) {
            if(not ((e.code == KeyCode.VK_UP) or (e.code == KeyCode.VK_DOWN))) {
                control.onKeyReleased(e);
            }
        }
        listView.onKeyTyped = function(e) {
            control.onKeyTyped(e);
        }
    }

    function show(x: Number, y: Number, visible: Boolean) {
        if(not visible) {
            showPopup = false;
            control.requestFocus();
            return;
        }

        // Ensure that we are not adding twice
        delete list from node.scene.content;
        insert list into node.scene.content;

        list.layoutX = x;
        showPopup = true;
    }

    override protected function getMinHeight(): Number { return 24; }
    override protected function getMinWidth(): Number { return 50; }
    override protected function getPrefHeight(width: Number): Number { return 24; }
    override protected function getPrefWidth(height: Number): Number { return 100; }

}

class SelectBoxBehavior extends Behavior {
    public override function callActionForEvent(e:KeyEvent):Void {
        if(e.code == KeyCode.VK_DOWN) {
            var x = node.localToScene(node.layoutBounds).minX + 2;
            var y = node.localToScene(node.layoutBounds).maxY + 3;
            show(x, y, true);
        } else if(e.code == KeyCode.VK_ESCAPE) {
            show(0, 0, false);
        }
    }
}
