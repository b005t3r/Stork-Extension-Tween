/**
 * User: booster
 * Date: 06/02/14
 * Time: 8:59
 */
package stork.tween {

public class TweenUtil {
    public static function totalDuration(tween:AbstractTweenNode):Number {
        if(tween.repeatCount == 0)
            return Infinity;

        if(tween.repeatCount == 1)
            return tween.delay + tween.duration;
        else
            return tween.delay + tween.repeatCount * tween.duration + (tween.repeatCount - 1) * tween.repeatDelay;
    }

    public function TweenUtil() { throw new Error("this is a static class"); }
}
}
