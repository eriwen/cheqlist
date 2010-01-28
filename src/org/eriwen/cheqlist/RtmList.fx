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
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.effect.*;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.*;
import javafx.scene.shape.Rectangle;

import org.eriwen.cheqlist.theme.Theme;

/**
 * @author Eric wendelin
 */

public class RtmList extends CustomNode {
    public-init var theme:Theme;
    public-init var listHeight:Number = 30.0;
    public-init var position:String;
    public-init var name:String;
    public-init var smart:Boolean;
    public-init var listId:String;
    public-init var clickedAction: function(String);
    public-init var deletedAction: function(MouseEvent);

    var currentEffect:Effect = Glow { level: 0.0 };
    def hoverEffect = Glow { level: 0.5 }

    def background = Rectangle {
        width: theme.paneWidth, height: listHeight
        blocksMouse: true
        cursor: Cursor.HAND
        effect: bind currentEffect
        onMouseClicked: function(e) { clickedAction(name) }
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
                Stop { color: theme.priorityNColor, offset: 0.0 },
                Stop { color: theme.backgroundColor, offset: 0.5 }
            ]
        }
    }
    def smartIcon = ImageView {
        image: Image { url: theme.smartImageUrl }
        translateX: 3, translateY: 4
        visible: smart
    }
    def listName = Label {
        translateX: 26, translateY: 4
        font: theme.normalFont, text: name,
        textFill: theme.foregroundColor
        width: theme.paneWidth - 70
    }
    def deleteButton = Button {
        translateX: theme.paneWidth - 60, translateY: 2
        text: 'Delete'
        width: 50, height: 24
        effect: ColorAdjust {
            hue: 0.0, saturation: 0.6
        }
        visible: if (position.equals("0")) then true else false
        onMouseClicked: deletedAction
    }

    override public function create():Node {
        return Group {
            content: [background, smartIcon, listName, deleteButton]
        }
    }
}
