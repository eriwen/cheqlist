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

import javafx.scene.text.Font;
import javafx.scene.paint.Color;

/**
 * @author Eric Wendelin
 */
public abstract class Theme {
    //Bounds
    public var thinbarWidth:Number;
    public var thinbarHeight:Number;
    public var paneWidth:Number;
    public var paneHeight:Number;
    public var stageWidth:Number;
    public var stageHeight:Number;

    //Fonts
    public var titleFont:Font;
    public var normalFont:Font;
    public var providerFont:Font;
    public var detailFont:Font;
    public var toasterFont:Font;

    //Colors
    public var foregroundColor:Color;
    public var backgroundColor:Color;
    public var dueDateTextColor:Color;
    public var overdueTextColor:Color;
    public var priority1Color:Color;
    public var priority2Color:Color;
    public var priority3Color:Color;
    public var priorityNColor:Color;

    //Images
    public var addImageUrl = "{__DIR__}images/add.gif";
    public var backImageUrl = "{__DIR__}images/back.gif";
    public var closeImageUrl = "{__DIR__}images/close.gif";
    public var contactsImageUrl = "{__DIR__}images/contacts.gif";
    public var deleteImageUrl = "{__DIR__}images/delete.gif";
    public var icon16ImageUrl = "{__DIR__}images/cheqlist_logo_16.png";
    public var icon32ImageUrl = "{__DIR__}images/cheqlist_logo_32.png";
    public var icon64ImageUrl = "{__DIR__}images/cheqlist_logo_64.png";
    public var listsImageUrl = "{__DIR__}images/lists.gif";
    public var logoImageUrl = "{__DIR__}images/cheqlist_logo_100.png";
    public var logoutImageUrl = "{__DIR__}images/logout.gif";
    public var notesImageUrl = "{__DIR__}images/notes.gif";
    public var searchImageUrl = "{__DIR__}images/search.gif";
    public var settingsImageUrl = "{__DIR__}images/settings.gif";
    public var smartImageUrl = "{__DIR__}images/smart.gif";
    public var tasksImageUrl = "{__DIR__}images/tasks.gif";
}
