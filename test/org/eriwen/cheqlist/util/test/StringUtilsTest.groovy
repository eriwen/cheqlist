package org.eriwen.cheqlist.util.test

import org.junit.After
import org.junit.AfterClass
import org.junit.Before
import org.junit.BeforeClass
import org.junit.Ignore
import org.junit.Test
import static org.junit.Assert.*

import groovy.util.slurpersupport.GPathResult
import org.eriwen.cheqlist.util.StringUtils

/**
 * Unit test class for <code>org.eriwen.cheqlist.util.StringUtils</code>
 *
 * @author <a href="http://eriwen.com">Eric Wendelin</a>
 */
class StringUtilsTest {
    private static StringUtils instance = null

    @Before void setUp() {
        instance = new StringUtils()
    }
    @After void tearDown() {
        instance = null
    }

    @Test void testTrimString() {
        assertEquals 'Trim length is wrong', instance.trimString('12345', 3), '123'
    }

    @Test void testFormatFriendlyDate() {
        fail 'not done yet'
    }

    @Test void testFormatFriendlyRepeat() {
        fail 'not done yet'
    }

    @Test void testIsOverdue() {
        fail 'not done yet'
    }

    @Test void testGetCurrentDayMillisAtMidnight() {
        fail 'not done yet'
    }
}

