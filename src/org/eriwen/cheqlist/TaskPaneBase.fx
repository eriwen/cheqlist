/*
 *  Copyright 2010 Eric Wendelin
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

import java.util.*;

import javafx.scene.control.Label;
import javafx.scene.control.TextBox;

import org.eriwen.cheqlist.control.SelectBox;
import org.eriwen.cheqlist.control.SelectBoxItem;

/**
 * Base class for interacting with individual tasks.
 *
 * @author <a href="http://eriwen.com">Eric Wendelin</a>
 */
public class TaskPaneBase extends Pane {
    package function createLabel(text:String) {
        Label { text: text, textFill: bind theme.foregroundColor, width: 100, height: 26 }
    }

    package function createTextField(id:String) {
        TextBox { id: id, selectOnFocus: true, columns: 26 }
    }
    
    package def prioritySelectBox:SelectBox = SelectBox {
        items: [
            SelectBoxItem { text: 'None', value: 'N' }
            SelectBoxItem { text: 'Low', value: '3' }
            SelectBoxItem { text: 'Medium', value: '2' }
            SelectBoxItem { text: 'High', value: '1' }
        ]
        width: 150, height: 26
    }

    package def listsSelectBox:SelectBox = SelectBox {
        width: 150, height: 26
        items: []
        blocksMouse: true
    }
    package var lists:List on replace {
        //Add options to List combo box
        delete listsSelectBox.items;
        insert SelectBoxItem { text: '', value: '' } into listsSelectBox.items;
        for (list in lists) {
            var listMap:LinkedHashMap = list as LinkedHashMap;
            //Do not add smart lists or archived to options
            if ((listMap.get('smart') as String).equals('0') and (listMap.get('archived') as String).equals('0')) {
                insert SelectBoxItem {
                    text: listMap.get('name') as String
                    value: listMap.get('id') as String
                } into listsSelectBox.items
            }
        }
        listsSelectBox.select(0);
    };

    package def locationsSelectBox:SelectBox = SelectBox {
        width: 150, height: 26
        items: []
        blocksMouse: true
    }
    package var locations:List on replace {
        //Add options for locations box
        insert SelectBoxItem { text: '', value: '' } into locationsSelectBox.items;
        for (loc in locations) {
            var locMap:LinkedHashMap = loc as LinkedHashMap;
            var item = SelectBoxItem {
                text: locMap.get('name') as String
                value: locMap.get('id') as String
            }
            insert item into locationsSelectBox.items
        }
        locationsSelectBox.select(0);
    };
}
