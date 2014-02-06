/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package stork.transition {
public class EaseOutInBounceTransition implements ITweenTransition {
    public function get name():String {
        return "Ease Out-In-Bounce";
    }

    public function value(v:Number):Number {
        return TweenTransitions.combine(TweenTransitions.EASE_OUT_BOUNCE, TweenTransitions.EASE_IN_BOUNCE, v);
    }
}
}
