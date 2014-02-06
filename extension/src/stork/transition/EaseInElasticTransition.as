/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package stork.transition {
public class EaseInElasticTransition implements ITweenTransition {
    public function get name():String {
        return "Ease In-Elastic";
    }

    public function value(v:Number):Number {
        if (v == 0 || v == 1) {
            return v;
        }
        else {
            const p:Number = 0.3;
            const s:Number = p / 4.0;
            var inv:Number = v - 1;

            return -1.0 * Math.pow(2.0, 10.0 * inv) * Math.sin((inv - s) * (2.0 * Math.PI) / p);
        }
    }
}
}
