/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package stork.transition {
public class EaseOutInElasticTransition implements ITweenTransition {
    public function get name():String {
        return "Ease Out-In-Elastic";
    }

    public function value(v:Number):Number {
        return TweenTransitions.combine(TweenTransitions.EASE_OUT_ELASTIC, TweenTransitions.EASE_IN_ELASTIC, v);
    }
}
}
