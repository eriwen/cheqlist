/*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
 * Copyright 2009 Sun Microsystems, Inc. All rights reserved. Use is subject to license terms.
 *
 * This file is available and licensed under the following license:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   * Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *
 *   * Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *
 *   * Neither the name of Sun Microsystems nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package org.eriwen.cheqlist.control;

import javafx.animation.Interpolator;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.scene.control.TextBox;
import javafx.scene.CustomNode;
import javafx.scene.Group;
import javafx.scene.Node;
import javafx.scene.paint.Color;
import javafx.scene.shape.Line;
import javafx.scene.shape.Rectangle;

import org.eriwen.cheqlist.control.Cell;

/**
 * @author Rakesh Menon, Eric Wendelin
 */

public class ColorPalette extends CustomNode {

    var color = [
        "000000", "333333", "666666", "999999", "CCCCCC", "FFFFFF", "FF0000", "00FF00", "0000FF",
        "000000", "000000", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
        "000000", "000033", "000066", "000099", "0000CC", "0000FF", "990000", "990033", "990066",
        "003300", "003333", "003366", "003399", "0033CC", "0033FF", "993300", "993333", "993366",
        "006600", "006633", "006666", "006699", "0066CC", "0066FF", "996600", "996633", "996666",
        "009900", "009933", "009966", "009999", "0099CC", "0099FF", "999900", "999933", "999966",
        "00CC00", "00CC33", "00CC66", "00CC99", "00CCCC", "00CCFF", "99CC00", "99CC33", "99CC66",
        "00FF00", "00FF33", "00FF66", "00FF99", "00FFCC", "00FFFF", "99FF00", "99FF33", "99FF66",
        "330000", "330033", "330066", "330099", "3300CC", "3300FF", "CC0000", "CC0033", "CC0066",
        "333300", "333333", "333366", "333399", "3333CC", "3333FF", "CC3300", "CC3333", "CC3366",
        "336600", "336633", "336666", "336699", "3366CC", "3366FF", "CC6600", "CC6633", "CC6666",
        "339900", "339933", "339966", "339999", "3399CC", "3399FF", "CC9900", "CC9933", "CC9966",
        "33CC00", "33CC33", "33CC66", "33CC99", "33CCCC", "33CCFF", "CCCC00", "CCCC33", "CCCC66",
        "33FF00", "33FF33", "33FF66", "33FF99", "33FFCC", "33FFFF", "CCFF00", "CCFF33", "CCFF66",
        "660000", "660033", "660066", "660099", "6600CC", "6600FF", "FF0000", "FF0033", "FF0066",
        "663300", "663333", "663366", "663399", "6633CC", "6633FF", "FF3300", "FF3333", "FF3366",
        "666600", "666633", "666666", "666699", "6666CC", "6666FF", "FF6600", "FF6633", "FF6666",
        "669900", "669933", "669966", "669999", "6699CC", "6699FF", "FF9900", "FF9933", "FF9966",
        "66CC00", "66CC33", "66CC66", "66CC99", "66CCCC", "66CCFF", "FFCC00", "FFCC33", "FFCC66",
        "66FF00", "66FF33", "66FF66", "66FF99", "66FFCC", "66FFFF", "FFFF00", "FFFF33", "FFFF66",
    ];

    public var selectedColor = Color.WHITE;
    public var selectedText = "#FFFFFF";

    var tempColor = selectedColor;
    var tempText = selectedText;

    var x = 0.0;
    var y = 0.0;
    def width = 249.0;
    def height = 152.0;

    var timeline = Timeline {
        keyFrames: [
            KeyFrame {
                time: 0s
                values: [
                    y => - (height + 3 - x)
                ]
            },
            KeyFrame {
                time: 250ms
                values: [
                    y => 5.0 tween Interpolator.EASEOUT
                ]
            }
        ]
    };

    public var show = false on replace {

        if(show) {
            timeline.rate = 1;
            timeline.playFromStart();
            visible = true;
        } else {
            timeline.rate = -1;
            timeline.time = 250ms;
            timeline.play();
        }
    }

    public override var visible = false on replace {
        if(not visible) {
            delete this from scene.content;
        }
    }

    override function create() : Node {

        clip = Rectangle {
            width: width
            height: height + 5
        }

        var index = 0;
        var grid = Group { };
        for(col in [0..19]) {
            for(row in [0..8]) {
                insert Cell {
                    row: row
                    col: col
                    color: color[index]
                    updateColor: updateColor
                    selectColor: selectColor
                } into grid.content;
                index++;
            }
        }

        var bgRect = Rectangle {
            fill: Color.web("#E7E8E9")
            stroke: Color.web("#A5A9AE")
            width: width
            height: height
        }

        var borderRect = Rectangle {
            fill: Color.TRANSPARENT
            stroke: Color.WHITE
            x: 1, y: 1
            width: width - 2, height: height - 2
        }

        var selColorRect = Rectangle {
            x: 4, y: 6
            width: 45, height: 24
            fill: bind tempColor
        }

        var selColorBorder = Group {
            translateX: 4, translateY: 6
            content: [
                Line { startX: 0  startY: 0 endX: selColorRect.width  endY: 0 stroke: Color.web("#999999") },
                Line { startX: 0  startY: 0 endX: 0  endY: selColorRect.height stroke: Color.web("#999999") },
                Line { startX: selColorRect.width  startY: 0 endX: selColorRect.width  endY: selColorRect.height stroke: Color.WHITE },
                Line { startX: 0  startY: selColorRect.height endX: selColorRect.width  endY: selColorRect.height stroke: Color.WHITE }
            ]
        }

        var selColorText = TextBox {
            translateX: 8 + selColorRect.width
            translateY: 6
            focusTraversable: false
            editable: false
            text: bind tempText
        };

        grid.translateX = 4;
        grid.translateY = 10 + selColorRect.height;

        Group {
            content: [ bgRect, borderRect, selColorRect, selColorBorder, grid, selColorText ]
            translateX: bind x
            translateY: bind y
        }
    }

    function updateColor(id : String, clr : Color) : Void {
        tempText = id;
        tempColor = clr;
    }

    function selectColor(id : String, clr : Color) : Void {
        selectedText = tempText;
        selectedColor = tempColor;
        show = false;
    }
}
