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
import java.util.concurrent.ExecutionException;
import javafx.animation.*;
import javafx.geometry.HPos;
import javafx.geometry.VPos;
import javafx.scene.*;
import javafx.scene.control.Button;
import javafx.scene.control.TextBox;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.*;
import javafx.scene.shape.Rectangle;

import org.eriwen.cheqlist.util.GroovyRtmUtils;
import org.eriwen.rtm.RtmService;

/**
 * @author Eric Wendelin
 */
package class ListsPane extends Pane {
    public-init var listClickedAction: function(String);
    public-init var updateListsAction: function();
    def listHeight:Number = 30.0;
    package var listsList = [];
    package var lists:List on replace {
        //Collections.sort(lists, listComparator);
        scrollIndicatorY = 0.0;
        scrollY = 0.0;
        delete listsList;
        for (list in lists) {
            var listMap = list as LinkedHashMap;
            if (listMap.get('archived').equals('0')) {
                insert listMap into listsList;
            }
        }
    };
    public-init var rtm:RtmService;
    public-init var rtmUtils:GroovyRtmUtils;
    def fadeoutScrollOpacity = 0.3;
    def fadeinScrollOpacity = 0.8;

    override var focusTraversable = true;
    
    def listsListContainer:VBox = VBox {
        translateX: 0, translateY: 45
        spacing: 1
        focusTraversable: false
        width: theme.paneWidth, height: theme.paneHeight - 174
        content: bind for (list in listsList) {
            var listMap = list as Map;
            var listName = listMap.get('name').toString();
            var listId = listMap.get('id').toString();
            RtmList {
                listId: listId
                name: listName
                smart: if (listMap.get('smart').toString().equals('0')) then false else true
                position: listMap.get('position').toString()
                theme: theme
                clickedAction: listClickedAction
                deletedAction: function(e) {
                    deleteList(listId);
                }
            }
        }
    }

    var scrollY:Number = 0.0 on replace {
        listsListClipView.clipY = scrollY;
    };
    def totalHeight = bind (listHeight + 1.0) * (sizeof listsList + 1.0);
    def clipHeight = 370.0;

    def listsListClipView:ClipView = ClipView {
        clipX: 0.0, clipY: 0.0
        node: listsListContainer
        pannable: false
        layoutInfo: LayoutInfo {
            width: theme.paneWidth, height: clipHeight
        }
        onMouseWheelMoved: function(e:MouseEvent):Void {
            if ((scrollY <= 0 and e.wheelRotation < 0) or
                    (scrollY >= (totalHeight - clipHeight + listHeight) and e.wheelRotation > 0)) {
                return;
            } else {
                scrollY += e.wheelRotation * (listHeight + 1.0);
                scrollIndicatorOpacity = fadeinScrollOpacity;
                //FIXME: do different math here
                scrollIndicatorY = 45 + scrollY * 0.7 * (clipHeight / totalHeight);
                (Timeline {
                    keyFrames: [
                        KeyFrame { time: 0.4s,
                            values: scrollIndicatorOpacity => fadeinScrollOpacity tween Interpolator.EASEIN
                        }
                        KeyFrame { time: 0.8s,
                            values: scrollIndicatorOpacity => fadeoutScrollOpacity tween Interpolator.EASEOUT
                        }
                    ]
                }).play();
            }
        }
    }

    var scrollIndicatorOpacity:Number = fadeoutScrollOpacity;
    var scrollIndicatorY:Number = 0.0;
    var scrollIndicatorHeight:Number = bind clipHeight * (clipHeight / totalHeight);
    var scrollIndicator:Rectangle = Rectangle {
        translateX: theme.paneWidth - 6, translateY: bind scrollIndicatorY
        arcHeight: 5, arcWidth: 5
        width: 4, height: bind scrollIndicatorHeight
        fill: bind theme.foregroundColor
        opacity: bind scrollIndicatorOpacity
        visible: bind if (totalHeight > clipHeight) then true else false
        onMouseEntered: function(e:MouseEvent):Void {
            (Timeline {
                keyFrames: [
                    KeyFrame { time: 0.1s,
                        values: scrollIndicatorOpacity => fadeinScrollOpacity tween Interpolator.EASEIN
                    }
                ]
            }).play();
        }
        onMouseExited: function(e:MouseEvent):Void {
            (Timeline {
                keyFrames: [
                    KeyFrame { time: 0.4s,
                        values: scrollIndicatorOpacity => fadeoutScrollOpacity tween Interpolator.EASEIN
                    }
                ]
            }).play();
        }
    }

    function addList(name:String, filter:String) {
        toaster.show('Adding list "{name}"...');
        rtmUtils.asyncTask(function () {
            rtm.listsAdd(name, filter);
        }, function (result):Void {
            if (result != null) {
                toaster.showTimed('List "{name}" added!', 1.5s);
                updateListsAction();
            }
        }, function (e:ExecutionException):Void {
            toaster.showTimed(e.getCause().getMessage());
        });
    }

    function deleteList(listId:String) {
        toaster.show('Deleting list...');
        rtmUtils.asyncTask(function () {
            rtm.listsDelete(listId);
        }, function (result):Void {
            if (result != null) {
                toaster.showTimed('List deleted', 1.5s);
                updateListsAction();
            }
        }, function (e:ExecutionException):Void {
            toaster.showTimed(e.getCause().getMessage());
        });
    }

    def titleGroup = Group {
        blocksMouse: true
        content: [
            Rectangle {
                height: 40, width: theme.paneWidth
                fill: bind theme.backgroundColor
            },
            panelTitle, backButton
        ]
    }

    def addListForm = Group {
        var addForm:VBox;
        def addHeight = 60;
        def nameTextBox:TextBox = TextBox {
            columns: 20, selectOnFocus: true,
            layoutInfo: LayoutInfo { width: 180, height: 24 }
            promptText: 'List Name'
        };
        def filterTextBox:TextBox = TextBox {
            columns: 25, selectOnFocus: true,
            layoutInfo: LayoutInfo { width: theme.paneWidth - 23, height: 24 }
            promptText: '(Optional) filter'
        };
        def addButton:Button = Button {
            layoutInfo: LayoutInfo { width: 80, height: 24 }
            text: "Add List",
            onMouseClicked: function(e:MouseEvent) {
                addList(nameTextBox.rawText, filterTextBox.rawText);
                nameTextBox.text = '';
                filterTextBox.text = '';
            }
        };
        
        translateY: theme.paneHeight - addHeight
        blocksMouse: true
        content: [
            Rectangle {
                width: theme.paneWidth, height: addHeight
                fill: bind theme.backgroundColor
            }
            addForm = VBox {
                translateX: 15, spacing: 5
                hpos: HPos.CENTER, vpos: VPos.CENTER
                content: [
                    HBox { spacing: 5, content: [nameTextBox, addButton] },
                    filterTextBox
                ]
            }
        ]
    }

    public override function create():Node {
        title = "Lists";
        toaster.hide();
        return Group {
            content: [
                background, 
                VBox { content: [listsListClipView] },
                scrollIndicator,
                titleGroup, addListForm, toaster
            ]
        }
    }
}
