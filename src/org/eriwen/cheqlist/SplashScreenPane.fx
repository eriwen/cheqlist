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

import javafx.scene.Node;
import javafx.scene.Group;
import javafx.scene.text.*;

import javafx.scene.control.ProgressBar;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;

/**
 * @author Eric Wendelin
 */

package class SplashScreenPane extends Pane {
    package var progress:Number = 0;
    package var statusMessage:String = 'Initializing Cheqlist...';

    override public function create():Node {
        var group:Group;
        return group = Group {
            blocksMouse: true
            content: [
                background,
                ImageView {
                    translateX: (theme.paneWidth / 2) - 50 translateY: (theme.paneHeight / 2) - 80
                    image: Image { url: theme.logoImageUrl }
                    preserveRatio: true, smooth: true
                }
                ProgressBar {
                    translateX: (theme.paneWidth / 2) - 75, translateY: (theme.paneHeight / 2) + 35
                    height: 8
                    progress: bind ProgressBar.computeProgress(100, progress)
                }
                Text {
                    font: theme.detailFont
                    fill: theme.foregroundColor
                    translateX: (theme.paneWidth / 2) - 74, translateY: (theme.paneHeight / 2) + 55
                    content: bind statusMessage
                }
                Text {
                    font: theme.detailFont
                    fill: theme.foregroundColor
                    translateX: (theme.paneWidth / 2) - 72, translateY: theme.paneHeight - 10
                    content: "Powered by Remember The Milk"
                }
            ]
        }
    }
}
