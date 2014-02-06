/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:03
 */
package stork.transition {
public class LinearTransition implements ITweenTransition {
    public function get name():String {
        return "Linear";
    }

    public function value(v:Number):Number {
        return v;
    }
}
}
