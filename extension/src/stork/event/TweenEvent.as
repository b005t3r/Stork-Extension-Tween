/**
 * User: booster
 * Date: 06/02/14
 * Time: 8:56
 */
package stork.event {
import stork.tween.AbstractTweenNode;

public class TweenEvent extends Event {
    public static const STARTED:String  = "startedTweenEvent";
    public static const FINISHED:String = "finishedTweenEvent";
    public static const ADVANCED:String = "advancedTweenEvent";
    public static const REPEATED:String = "repeatedTweenEvent";

    public static const INVALIDATED:String = "invalidatedTweenEvent";

    public function TweenEvent(type:String) {
        super(type, false);
    }

    public function get tween():AbstractTweenNode { return target as AbstractTweenNode; }

}
}
