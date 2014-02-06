/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package stork.transition {
public class EaseInOutBackTransition implements ITweenTransition {
    public function get name():String {
        return "Ease In-Out-Back";
    }

    public function value(v:Number):Number {
        return TweenTransitions.combine(TweenTransitions.EASE_IN_BACK, TweenTransitions.EASE_OUT_BACK, v);
    }
}
}
