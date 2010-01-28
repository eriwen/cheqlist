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

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 * String utilities for use with Cheqlist
 *
 * @author Eric Wendelin
 */

public class StringUtils {
    SimpleDateFormat rawDueDateFormat = new SimpleDateFormat("yyyy-MM-ddHH:mm:ss");
    SimpleDateFormat defaultDateFmt = new SimpleDateFormat("MMM dd");
    SimpleDateFormat dayOfWeekFmt = new SimpleDateFormat("EEEE");
    SimpleDateFormat timeOfDayFmt = new SimpleDateFormat("HH:mm:ss");
    SimpleDateFormat friendlyTimeFmt = new SimpleDateFormat("H:mm");
    int dayInMillis = 3600000 * 24;
    int weekInMillis = dayInMillis * 7;

    /**
     * Trim the string if length is greater than specified length
     *
     * @param string The string to truncate
     * @param length The preferred length of the returned String
     */
    public String trimString(String string, int length) {
        if(string == null) {
            return "";
        } else if(string.length() > length) {
            return string.substring(0, length).trim();
        }
        return string;
    }

    /**
     * Given a date in the form YYYY-MM-DDTHH:MM:SSZ, return a friendly date
     * like "Tuesday" or "Mar 9" or "11:00AM"
     *
     * @param dateStr the date to parse as a String
     */
    public String formatFriendlyDate(String dateStr, String hasDueTime, Integer timezoneOffset) {
        long nowMillis = getCurrentDayMillisAtMidnight(timezoneOffset);
        Date taskDate;

        //Return "Never" for nothing or error
        try {
            taskDate = rawDueDateFormat.parse(trimString(dateStr, 10) + dateStr.substring(11, 19));
        } catch (NullPointerException npe) {
            return "Never";
        } catch (ParseException pe) {
            return "Never";
        } catch (StringIndexOutOfBoundsException sioobe) {
            //Occurs with dates before 1990 or something
            return "Never";
        }

        long taskMillis = taskDate.getTime();
        taskDate.setTime(taskMillis + (timezoneOffset * 1000));
        boolean isToday = taskMillis >= nowMillis && taskMillis < nowMillis + dayInMillis;
        String friendlyDate;
        if (taskMillis >= nowMillis && taskMillis < (nowMillis + weekInMillis)) {
            if (taskMillis == nowMillis || (isToday && hasDueTime.equals("0"))) {
                friendlyDate = "Today";
            } else if (isToday && hasDueTime.equals("1")) {
                friendlyDate = friendlyTimeFmt.format(taskDate);
            } else if (taskMillis == nowMillis + dayInMillis) {
                friendlyDate = "Tomorrow";
            } else {
                //Return day of week if within a week from now
                friendlyDate = dayOfWeekFmt.format(taskDate);
            }
        } else {
            //Otherwise return MMM dd
            friendlyDate = defaultDateFmt.format(taskDate);
        }
        //println("dateStr {dateStr}, offset {timezoneOffset},  hasduetime {hasDueTime}, tasktime {taskMillis}, nowtime {nowMillis}, diff {taskMillis - nowMillis} - {friendlyDate}");
        return friendlyDate;
    }

    public String formatFriendlyDate(String dateStr, String hasDueTime) {
        return formatFriendlyDate(dateStr, hasDueTime, 0);
    }

    /**
     * Given a String representing the RTM repeat, return a friendly repeat
     * String value
     *
     * @param the repeat string to format
     * @return formatted repeat string like "every 3 blahs"
     */
    public String formatFriendlyRepeat(String repeatStr) {
        //Format is FREQ=MONTHLY;INTERVAL=1 or INTERVAL=4;FREQ=DAILY
        if (repeatStr == null || repeatStr.equals("")) {
            return "";
        }
        String[] repeatTerms = repeatStr.split(";");
        String freq = "";
        int interval = 0;
        for (String repeatTerm : repeatTerms) {
            int equalsPosition = repeatTerm.indexOf("=");
            if (repeatTerm.startsWith("INTERVAL")) {
                interval = Integer.parseInt(repeatTerm.substring(equalsPosition + 1));
            } else {
                freq = repeatTerm.substring(5, repeatTerm.length() - 2).toLowerCase();
                //Everything but days can be converted this way. HOURLY, DAILY, WEEKLY, MONTHLY, YEARLY
                if (freq.equals("dai")) {
                    freq = "day";
                }
            }
        }
        String friendlyRepeat = "every " + interval + " " + freq;
        if (interval > 1) {
            friendlyRepeat += "s";
        }
        return friendlyRepeat;
    }

    /**
     * Given a date string, return if the date is overdue
     *
     * @param dateStr the date to check
     * @return True if the date is overdue (past today ignoring time)
     */
    public boolean isOverdue(String dateStr, int timezoneOffset) {
        //Check for null date
        if (dateStr == null || dateStr.equals("")) {
            return false;
        }
        Date taskDate;
        try {
            taskDate = rawDueDateFormat.parse(trimString(dateStr, 10) + dateStr.substring(11, 19));
            if ((getCurrentDayMillisAtMidnight(timezoneOffset) - taskDate.getTime()) > 0) {
                return true;
            }
            return false;
        } catch (ParseException pe) {
            pe.printStackTrace();
            return false;
        }
    }

    public long getCurrentDayMillisAtMidnight(long timezoneOffset) {
        Calendar now = Calendar.getInstance();
        now.set(Calendar.HOUR_OF_DAY, 0);
        now.set(Calendar.MINUTE, 0);
        now.set(Calendar.SECOND, 0);
        now.set(Calendar.MILLISECOND, 0);
        //Isn't java.util.Calendar great?
        long nowMillis = now.getTimeInMillis();
        nowMillis -= timezoneOffset * 1000;
        return nowMillis;
    }
}
