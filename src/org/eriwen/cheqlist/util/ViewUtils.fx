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
package org.eriwen.cheqlist.util;

import java.awt.AWTException;
import java.awt.SystemTray;
import java.awt.TrayIcon;
import java.awt.event.ActionListener;
import javafx.stage.Screen;

import javafx.scene.image.Image;

import org.eriwen.cheqlist.*;
import org.eriwen.cheqlist.theme.*;
//import org.jfxtras.menu.*;

/**
 * @author Eric Wendelin
 */

public class ViewUtils {
    public-init var theme:Theme;
    public var thinbar:Thinbar = null;
    public-init var settings:Settings;

    /**
     * @return true (meaning Cheqlist should orient the thinbar on the right and open
     * panes right) if the thinbar is close enough to the right of the primary
     * display that the pane will not fit on the screen
     */
    function getDoOpenLeft():Boolean {
        return (Main.stageX + thinbar.translateX) > (Screen.primary.bounds.maxX - theme.paneWidth);
    }

    /**
     * Adds a pane to the main scene then moves the thinbar and pane around
     * depending on Cheqlist orientation
     *
     * @param the Pane to open on the side
     */
    public function openSidebar(pane:Pane):Void {
        addPane(pane);
        if (getDoOpenLeft()) {
            Main.stageX -= theme.paneWidth;
            thinbar.translateX = theme.paneWidth;
            pane.translateX = 0;
        } else {
            thinbar.translateX = 0;
            pane.translateX = theme.thinbarWidth;
        }
        theme.stageWidth = theme.thinbarWidth + theme.paneWidth;
    }

    public function openAuthSidebar(pane:Pane):Void {
        insert pane into Main.authScene.content;
        if (getDoOpenLeft()) {
            Main.stageX -= theme.paneWidth;
            thinbar.translateX = theme.paneWidth;
            pane.translateX = 0;
        } else {
            thinbar.translateX = 0;
            pane.translateX = theme.thinbarWidth;
        }
        theme.stageWidth = theme.thinbarWidth + theme.paneWidth;
    }

    /**
     * Given a pane, opens it if it's not currently open. If so, closes it.
     *
     * @param the Pane to either open or close
     */
    public function toggleSidebar(pane:Pane):Void {
        if (pane == null) {
            closeAllPanes();
        } else if (sizeof Main.mainScene.content[n | n == pane] > 0) {
            if (not getDoOpenLeft()) {
                thinbar.translateX = 0;
            }
            closeSidebar(pane);
        } else {
            closeAllPanes();
            openSidebar(pane);
        }
    }

    function closeAllPanes():Void {
        for (obj in Main.mainScene.content) {
            if (obj instanceof Pane) {
                closeSidebar(obj as Pane);
            }
        }
    }


    /**
     * Remove the pane from the main scene. Precondition: There should never be
     * more than 2 items in the main scene: A pane and the Thinbar.
     */
    function removePane(pane:Pane):Void {
        delete pane from Main.mainScene.content;
    }

    /**
     * Adds given pane to the main scene always in the second position
     * (above the thinbar). Precondition: Only the thinbar must exist in the
     * scene before adding the pane.
     *
     * @param the Pane to add to the scene
     */
    function addPane(pane:Pane):Void {
        insert pane into Main.mainScene.content;
    }

    /**
     * Removes the pane and then moves the thinbar and stage around accordingly
     */
    public function closeSidebar(pane:Pane):Void {
        removePane(pane);
        thinbar.toFront();
        if (getDoOpenLeft()) {
            thinbar.translateX = 0;
            Main.stageX += theme.paneWidth;
        }
        theme.stageWidth = theme.thinbarWidth;
    }

    public function showSystemTrayIcon():Void {
        var trayIconImage = Image {
            url: "{__DIR__}../theme/images/cheqlist_logo_16.png"
        }

        if (SystemTray.isSupported()) {
            var tray:TrayIcon = new TrayIcon(trayIconImage.platformImage as java.awt.Image);
            tray.setImage(trayIconImage.platformImage as java.awt.Image);
            //tray.setPopupMenu(createNativeMainMenu(null).getPopupMenu())
            tray.setToolTip("Cheqlist 0.2");
            tray.addActionListener(ActionListener {
                override function actionPerformed(e) {
                    //Show or hide cheqlist
                    thinbar.toFront();
                }
            });
            try {
                SystemTray.getSystemTray().add(tray);
            } catch (e:AWTException) {
                e.printStackTrace();
            }
        }
    }

    /*public function createNativeMainMenu(parent:java.awt.Component):NativePopupMenu {
        return NativePopupMenu {
            parent: parent
            items: [
                NativeMenuSeparator {},
                NativeCheckboxMenuItem {
                    text: "Always on Top"
                    selected: bind alwaysOnTop with inverse;
                },
                NativeMenuSeparator {},
                NativeMenuItem {
                    text: bind if (visible) "Hide" else "Show"
                    action: function() {
                        if (visible) {
                            hideCheqlist();
                        } else {
                            showCheqlist();
                        }
                    }
                },
                NativeMenuItem {
                    text: "Exit"
                    action: function() {
                        FX.exit();
                    }
                }
            ]
        }
    }*/
}
