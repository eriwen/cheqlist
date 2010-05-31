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
package org.eriwen.cheqlist.control;

import javafx.scene.control.ChoiceBox;

/**
 * @author <a href="http://eriwen.com">Eric Wendelin</a>
 */
public class SelectBox extends ChoiceBox {
    override public def items = [] as SelectBoxItem[];

    public function selectByValue(value:String):Void {
        for (entry in [0..(sizeof items - 1)]) {
            if ((items[entry] as SelectBoxItem).value.equals(value)) {
                select(entry);
                break;
            }
        }
    }
}
