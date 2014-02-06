/**
 * User: booster
 * Date: 06/02/14
 * Time: 9:55
 */
package stork.event {
import stork.tween.TimeFrameNode;

public class TimeFrameEvent extends Event {
    public static const INVALIDATED:String = "invalidatedTimeFrameEvent";

    public function TimeFrameEvent(type:String) {
        super(type, false);
    }

    public function get timeFrame():TimeFrameNode { return target as TimeFrameNode; }
}
}
