/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package stork.transition {
public class EaseInBackTransition implements ITweenTransition {
    public function get name():String {
        return "Ease In-Back";
    }

    public function value(v:Number):Number {
        const s:Number = 1.70158;

        return v * v * ((s + 1.0) * v - s);
    }
}
}
