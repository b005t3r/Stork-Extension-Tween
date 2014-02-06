/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package stork.transition {
public class EaseOutBackTransition implements ITweenTransition {
    public function get name():String {
        return "Ease Out-Back";
    }

    public function value(v:Number):Number {
        const s:Number = 1.70158;
        var inv:Number = v - 1.0; // 1 -> 0

        return inv * inv * ((s + 1.0) * inv + s) + 1.0;
    }
}
}
