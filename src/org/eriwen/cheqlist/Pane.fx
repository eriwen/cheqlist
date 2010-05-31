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

import java.util.concurrent.ExecutionException;

import javafx.scene.Cursor;
import javafx.scene.CustomNode;
import javafx.scene.Group;
import javafx.scene.effect.Glow;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.scene.text.*;

import org.eriwen.cheqlist.theme.*;

/**
 * Base class for all Cheqlist Panes.
 *
 * @author Eric Wendelin
 */
public abstract class Pane extends CustomNode {
    package var closeAction = function(e:MouseEvent) {}
    package var theme:Theme;
    package var title:String = "";

    package def panelTitle = Text {
        x: 80, y: 30
        font: theme.titleFont
        fill: bind theme.foregroundColor
        content: bind title
    }

    package def backButton:Group = Group {
        translateX: theme.paneWidth - 32, translateY: 5,
        onMouseClicked: closeAction
        onMouseEntered: function(e:MouseEvent): Void {
            backButton.effect = Glow { level: 0.4 }
        };
        onMouseExited: function(e:MouseEvent): Void {
            backButton.effect = Glow { level: 0.0 }
        };
        cursor: Cursor.HAND
        content: [
            Rectangle {
                width: 32, height: 32
                fill: Color.TRANSPARENT
            },
            ImageView {
                image: Image { url: theme.closeImageUrl }
            }
        ]
    }

    package def background = Rectangle {
        blocksMouse: true,
        width: theme.paneWidth, height: theme.paneHeight,
        fill: bind theme.backgroundColor
    }

    package def toaster = Toaster {
        toasterHeight: 40
        theme: theme
    }

    package function showToasterError(e:ExecutionException):Void {
        toaster.show(e.getCause().getMessage());
    }
}
