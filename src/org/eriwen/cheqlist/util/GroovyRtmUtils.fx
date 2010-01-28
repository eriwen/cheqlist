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

import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.concurrent.ExecutionException;
import org.jfxtras.async.XWorker;

/**
 * Contains utility functions for dealing with Groovy RTM
 *
 * @author Eric Wendelin
 */

public class GroovyRtmUtils {
    public function asyncTask(task:function():Object,
            callback:function(result:Object):Void, errorCB:function(e:ExecutionException)):Void {
        XWorker {
            inBackground: task
            onDone: callback
            onFailure: errorCB
        }
    }

    public function groovyRtmErrorHandler(e:ExecutionException):Void {
        //FIXME: Show dialog explaining error
        println(e.getMessage())
    }

    public function loadRtmCollection(task:function():Object, callback:function(result:Object):Void):Void {
        asyncTask(task, callback, groovyRtmErrorHandler)
    }

    public def smartComparator:Comparator = Comparator {
        public override function compare(o1: Object, o2: Object):Integer {
            var c1 = (o1 as LinkedHashMap).get('due').toString();
            var c2 = (o2 as LinkedHashMap).get('due').toString();
            if (c1 == null or c1 == "") return 1;
            if (c2 == null or c2 == "") return -1;
            if (c1.compareTo(c2) == 0) {
                return comparePriority(o1, o2);
            }
            return c1.compareTo(c2);
        }

        public function comparePriority(o1: Object, o2: Object):Integer {
            var c1 = (o1 as LinkedHashMap).get('priority').toString();
            var c2 = (o2 as LinkedHashMap).get('priority').toString();
            if (c1 == "N") return 1;
            if (c2 == "N") return -1;
            //Higher number ~= lower priority
            return Integer.parseInt(c1).compareTo(Integer.parseInt(c2));
        }
    };
    public def dueDateComparator:Comparator = Comparator {
        public override function compare(o1: Object, o2: Object):Integer {
            var c1 = (o1 as LinkedHashMap).get('due').toString();
            var c2 = (o2 as LinkedHashMap).get('due').toString();
            if (c1 == null or c1 == "") return 1;
            if (c2 == null or c2 == "") return -1;
            return c1.compareTo(c2);
        }
    };
    public def priorityComparator:Comparator = Comparator {
        public override function compare(o1: Object, o2: Object):Integer {
            var c1 = (o1 as LinkedHashMap).get('priority').toString();
            var c2 = (o2 as LinkedHashMap).get('priority').toString();
            if (c1 == "N") return 1;
            if (c2 == "N") return -1;
            //Higher number ~= lower priority
            return Integer.parseInt(c1).compareTo(Integer.parseInt(c2));
        }
    };
    public def nameComparator:Comparator = Comparator {
        public override function compare(o1: Object, o2: Object):Integer {
            var c1 = (o1 as LinkedHashMap).get('name').toString();
            var c2 = (o2 as LinkedHashMap).get('name').toString();
            if (c1 == null or c1.equals("")) return 1;
            if (c2 == null or c2.equals("")) return -1;
            return c1.compareTo(c2);
        }
    };
}
