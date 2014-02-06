/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package stork.transition {

public class EaseOutElasticTransition implements ITweenTransition {
    public function get name():String {
        return "Ease Out-Elastic";
    }

    public function value(v:Number):Number {
        if (v == 0 || v == 1) {
            return v;
        }
        else {
            const p:Number = 0.3;
            const s:Number = p / 4.0;

            return Math.pow(2.0, -10.0 * v) * Math.sin((v - s) * (2.0 * Math.PI) / p) + 1;
        }
    }
}
}
