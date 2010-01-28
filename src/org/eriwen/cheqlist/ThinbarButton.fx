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
import javafx.scene.effect.Glow;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.scene.text.*;
import org.eriwen.cheqlist.Pane;
import org.eriwen.cheqlist.theme.Theme;
import org.eriwen.cheqlist.util.ViewUtils;

/**
 * @author Eric Wendelin
 */

package class ThinbarButton extends CustomNode {
    public-init var theme:Theme;
    public-init var viewUtils:ViewUtils;
    public-init var pane:Pane;
    public-init var image:Image;
    public-init var tooltip:String;
    package var showTooltip:Boolean;
    var tooltipOpacity = 0.0;

    public override var cursor = Cursor.HAND;
    public override var blocksMouse = true;
    public override var onMouseClicked = function(e:MouseEvent): Void {
        viewUtils.toggleSidebar(pane);
    };
    public override var onMouseEntered = function(e:MouseEvent): Void {
        if (showTooltip) {
            tooltipOpacity = 0.9;
        }
        this.effect = Glow { level: 0.4 }
    };
    public override var onMouseExited = function(e:MouseEvent): Void {
        if (showTooltip) {
            tooltipOpacity = 0.0;
        }
        this.effect = Glow { level: 0.0 }
    };

    var tooltipGroup:Group = Group {
        opacity: bind tooltipOpacity
        rotate: 45
        translateY: 13
        content: [
            Rectangle {
                width: 45, height: 13
                fill: bind theme.backgroundColor
            }
            Text {
                font: Font { size: 9 }
                translateY: 12
                fill: bind theme.foregroundColor
                content: tooltip
            }
        ]
    }

    public override function create():Node {
        var group:Group;
        return group = Group {
            content: [
                ImageView {
                    image: image
                },
                tooltipGroup,
                Rectangle {
                    width: theme.thinbarWidth, height: 32
                    fill: Color.TRANSPARENT
                }
            ]
        }
    }
}
