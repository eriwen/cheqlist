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
import javafx.scene.effect.ColorAdjust;
import javafx.scene.shape.Rectangle;
import javafx.scene.paint.*;
import javafx.scene.text.*;
import javafx.animation.*;

import org.eriwen.cheqlist.theme.Theme;

/**
 * A toaster widget that pops up from the bottom of the node it is applied to
 * with a message and fades away
 *
 * @author Eric Wendelin
 */
package class Toaster extends CustomNode {
    package var toasterMessage:String = '';
    public-init var theme:Theme;
    public-init var toasterWidth:Number = theme.paneWidth - 14;
    public-init var toasterHeight:Number = 36;
    public-init var initX:Number = theme.thinbarWidth;
    public-init var initY:Number = theme.stageHeight;
    public-init var backgroundColor:Color = bind theme.backgroundColor;
    public-init var color:Color = bind theme.foregroundColor;
    public-init var showTime = 2.5s;

    def background = Rectangle {
        arcWidth: 17, arcHeight: 17
        translateX: 7
        width: toasterWidth, height: toasterHeight
        fill: bind backgroundColor
        effect: ColorAdjust {
            hue: 0.35, saturation: 0.6, brightness: 0.4
        }
        blocksMouse: true
    }

    def message = Text {
        translateX: 15, translateY: 15
        font: theme.toasterFont
        wrappingWidth: toasterWidth - (this.translateX * 3)
        fill: bind color
        content: bind toasterMessage
    }

    def closeButton = Group {
        translateX: toasterWidth - 10, translateY: 5,
        content: [
            Rectangle {
                height: 12, width: 12, arcHeight: 9, arcWidth: 9
                fill: theme.backgroundColor
            }
            Text { 
                translateX: 3, translateY: 9,
                content: 'x', fill: theme.foregroundColor
            }
        ]
        cursor: Cursor.HAND
        onMouseClicked: function(e) {
            hide();
        }
    }

    def showKeyFrames:KeyFrame[] = [
        KeyFrame { time: 0.5s,
            values: this.translateY => initY - toasterHeight - 5 tween Interpolator.EASEIN
        }
    ];

    def hideKeyFrames:KeyFrame[] = [
        KeyFrame { time: if (showTime < 1s) then 1s else showTime,
            values: this.opacity => 0.9 tween Interpolator.LINEAR
        },
        KeyFrame { time: (if (showTime < 1s) then 1s else showTime) + 0.5s,
            values: this.opacity => 0.0 tween Interpolator.LINEAR
            action: function() {
                this.translateY = initY;
            }
        }
    ];
    
    /**
     * Shows this with the passed message until explicitly hidden
     *
     * @param message The text to show in the toaster
     */
    package function show(message:String):Void {
        this.opacity = 0.9;
        toasterMessage = message;
        (Timeline {
            keyFrames: showKeyFrames
        }).play();
    }

    /**
     * Shows this for a pre-determined time with the passed message
     *
     * @param message The text to show in the toaster
     */
    package function showTimed(message:String):Void {
        this.opacity = 0.9;
        toasterMessage = message;
        (Timeline {
            keyFrames: [showKeyFrames, hideKeyFrames]
        }).play();
    }

    /**
     * Shows this for a given duration with the passed message
     *
     * @param message The text to show in the toaster
     */
    package function showTimed(message:String, duration:Duration):Void {
        this.opacity = 0.9;
        toasterMessage = message;
        (Timeline {
            keyFrames: [
                showKeyFrames,
                KeyFrame { time: duration,
                    values: this.opacity => 0.9 tween Interpolator.LINEAR
                },
                KeyFrame { time: duration + 0.5s,
                    values: this.opacity => 0.0 tween Interpolator.LINEAR
                    action: function() {
                        this.translateY = initY;
                    }
                }]
        }).play();
    }

    /**
     * Hide toaster immediately
     */
    package function hide():Void {
        this.opacity = 0.0;
        this.translateY = initY;
    }

    /**
     * Hide toaster by fading it out
     */
    public function fadeOut():Void {
        (Timeline {
            keyFrames: hideKeyFrames
        }).play();
    }

    public override function create():Node {
        return Group {
            content: [background, message, closeButton]
        }
    }
}
