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

import javafx.scene.control.Control;

/**
 * @author Eric Wendelin
 */

public class SelectBox extends Control {
    override var skin = SelectBoxSkin {};

    public var options:SelectBoxItem[] = [];
    public-read var selectedItem = bind (skin as SelectBoxSkin).listView.selectedItem;

    public function select(index:Integer):Void {
        (skin as SelectBoxSkin).listView.select(index);
    }
    public function selectByValue(value:String):Void {
        for (entry in [0..(sizeof options - 1)]) {
            if (options[entry].value.equals(value)) {
                select(entry);
                break;
            }
        }
    }
    public function selectFirstRow():Void {
        (skin as SelectBoxSkin).listView.selectFirstRow();
    }
    public function selectLastRow():Void {
        (skin as SelectBoxSkin).listView.selectLastRow();
    }
    public function selectNextRow():Void {
        (skin as SelectBoxSkin).listView.selectNextRow();
    }
    public function selectPreviousRow():Void {
        (skin as SelectBoxSkin).listView.selectPreviousRow();
    }
}
