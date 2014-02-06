/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package stork.transition {
public class EaseInOutElasticTransition implements ITweenTransition {
    public function get name():String {
        return "Ease In-Out-Elastic";
    }

    public function value(v:Number):Number {
        return TweenTransitions.combine(TweenTransitions.EASE_IN_ELASTIC, TweenTransitions.EASE_OUT_ELASTIC, v);
    }
}
}
