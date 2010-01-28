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
package org.eriwen.cheqlist.theme;

import javafx.scene.paint.Color;
import javafx.scene.text.Font;

import org.eriwen.cheqlist.theme.Theme;

/**
 * @author Eric Wendelin
 */
public class DarkTheme extends Theme {
    //Bounds
    public override var thinbarWidth = 32;
    public override var thinbarHeight = 450;
    public override var paneHeight = thinbarHeight;
    public override var paneWidth = 288;
    public override var stageWidth = thinbarWidth + paneWidth;
    public override var stageHeight = thinbarHeight;

    // Fonts
    public override var titleFont = Font { name:"Helvetica", size: 24 };
    public override var normalFont = Font { name:"Helvetica", size: 14 };
    public override var providerFont = Font { name:"Helvetica", size: 10 };
    public override var detailFont = Font { name:"Helvetica", size: 9 };
    public override var toasterFont = Font { name:"Helvetica", size: 12 };

    //Colors
    public override var foregroundColor = Color.WHITE;
    public override var backgroundColor = Color.BLACK;
    public override var dueDateTextColor = Color.web("#DDDDDD");
    public override var overdueTextColor = Color.web("#FFFF66");
    public override var priority1Color = Color.web("#EA5500");
    public override var priority2Color = Color.web("#0060BF");
    public override var priority3Color = Color.web("#359AFF");
    public override var priorityNColor = Color.web("#666666");
}
