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

import javafx.scene.control.TextBox;
import javafx.scene.input.KeyEvent;
import javafx.scene.input.KeyCode;

/**
 * An implementation of TextBox that has an onChange event we can use for
 * live editing.
 *
 * @author Eric Wendelin
 */

public class LiveEditTextBox extends TextBox {
    var originalKeyReleased:function(event:KeyEvent);
    public-init var onChange:function(value:String);

    // the value should be sent when the control loses focus
    override public-read var focused on replace {
        // fire onChange when focus is lost
        if (not focused) {
            if (onChange != null) {
                onChange(text);
            }
        }
    };

    postinit {
        // keep a reference to the original key listener
        originalKeyReleased = this.onKeyReleased;
        // put our implementation in place
        this.onKeyReleased = interceptKey;
    }

    function interceptKey(event:KeyEvent) {
        if (onChange != null) {
            // if the user pressed enter or tab, send the value
            if (event.code == KeyCode.VK_TAB or event.code == KeyCode.VK_ENTER) {
                onChange(text);
            }
        }
        if (originalKeyReleased != null) {
            originalKeyReleased(event);
        }
    }
}
