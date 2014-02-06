/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package stork.transition {
public class EaseInOutTransition implements ITweenTransition {
    public function get name():String {
        return "Ease In-Out";
    }

    public function value(v:Number):Number {
        return TweenTransitions.combine(TweenTransitions.EASE_IN, TweenTransitions.EASE_OUT, v);
    }
}
}
