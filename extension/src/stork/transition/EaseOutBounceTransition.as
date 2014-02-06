/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package stork.transition {
public class EaseOutBounceTransition implements ITweenTransition {
    public function get name():String {
        return "Ease Out-Bounce";
    }

    public function value(v:Number):Number {
        const s:Number = 7.5625;
        const p:Number = 2.75;

        var l:Number;

        if(v < (1.0 / p)) {
            l = s * v * v;
        }
        else {
            if(v < (2.0 / p)) {
                v -= 1.5 / p;
                l = s * v * v + 0.75;
            }
            else {
                if(v < 2.5 / p) {
                    v -= 2.25 / p;
                    l = s * v * v + 0.9375;
                }
                else {
                    v -= 2.625 / p;
                    l = s * v * v + 0.984375;
                }
            }
        }
        return l;
    }
}
}
