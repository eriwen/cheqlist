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

import javafx.scene.CustomNode;
import javafx.scene.Node;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;

/**
 * @author Rakesh Menon
 */

public class Cell extends CustomNode {

    public-init var color : String;
    public-init var row : Integer;
    public-init var col : Integer;
    public-init var updateColor: function(id : String, clr : Color) = null;
    public-init var selectColor: function(id : String, clr : Color) = null;

    def size = 12;

    var rectangle = Rectangle {
        id: "#{color}"
        x: col * size
        y: row * size
        width: size
        height: size
        strokeWidth: 1.0
        stroke: Color.BLACK
        fill: Color.web("#{color}")
    };

    override function create() : Node {
        blocksMouse = true;
        focusTraversable = false;
        rectangle;
    }

    override var onMouseReleased = function(e) {
        selectColor(rectangle.id, rectangle.fill as Color);
    }

    override var onMouseMoved = function(e) {
        updateColor(rectangle.id, rectangle.fill as Color);
    }

    override var onMouseEntered = function(e) {
        rectangle.stroke = Color.WHITE;
        toFront();
    }

    override var onMouseExited = function(e) {
        rectangle.stroke = Color.BLACK;
    }
}

