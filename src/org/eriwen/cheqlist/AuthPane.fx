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
import javafx.scene.control.Button;
import javafx.scene.input.MouseEvent;
import javafx.scene.text.*;

/**
 * Pane containing the authorization dialog presented before the first
 * application startup
 * 
 * @author Eric Wendelin
 */

package class AuthPane extends Pane {
    public-init var authorizeAction:function(MouseEvent);

    def authorizeButton:Button = Button {
        text: 'Done'
        translateX: (theme.paneWidth - 60) / 2 - 5, translateY: 220
        onMouseClicked: function(e) {
            authorizeButton.text = 'Thanks!';
            authorizeButton.disable = true;
            authorizeAction(e);
        }
    }

    override public function create():Node {
        title = "Authorize Me";
        panelTitle.x = 55;
        toaster.hide();
        return Group {
            content: [
                background, panelTitle,
                Text {
                    fill: theme.foregroundColor
                    translateX: 15, translateY: 90
                    content: 'Opening browser...'
                },
                Text {
                    fill: theme.foregroundColor
                    translateX: 15, translateY: 130
                    content: 'Please login and allow Cheqlist access to Remember The Milk'
                    wrappingWidth: theme.paneWidth - 20
                },
                Text {
                    fill: theme.foregroundColor
                    translateX: 15, translateY: 190
                    content: 'Click "Done" after authorizing'
                    wrappingWidth: theme.paneWidth - 40
                },
                authorizeButton,
                Text {
                    fill: theme.foregroundColor
                    translateX: 15, translateY: 345
                    content: 'This product uses the Remember The Milk API but is not endorsed or certified by Remember The Milk.'
                    wrappingWidth: theme.paneWidth - 40
                },
                //TODO: Make this a link?
                Text {
                    font: theme.detailFont
                    fill: theme.foregroundColor
                    translateX: 57, translateY: theme.paneHeight - 10
                    content: "Powered by Remember The Milk"
                },
                toaster
            ]
        }
    }
}
