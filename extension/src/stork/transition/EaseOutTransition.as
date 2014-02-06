/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:03
 */
package stork.transition {
public class EaseOutTransition implements ITweenTransition {
    public function get name():String {
        return "Ease Out";
    }

    public function value(v:Number):Number {
        var inv:Number = v - 1.0; // 1 -> 0

        return inv * inv * inv + 1;
    }
}
}
