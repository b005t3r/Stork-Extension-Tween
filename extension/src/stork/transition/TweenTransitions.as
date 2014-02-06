/**
 * User: booster
 * Date: 8/29/13
 * Time: 9:24
 */

package stork.transition {
import flash.utils.Dictionary;

public class TweenTransitions {
    public static const LINEAR:ITweenTransition                 = new LinearTransition();

    public static const EASE_IN:ITweenTransition                = new EaseInTransition();
    public static const EASE_OUT:ITweenTransition               = new EaseOutTransition();
    public static const EASE_IN_OUT:ITweenTransition            = new EaseInOutTransition();
    public static const EASE_OUT_IN:ITweenTransition            = new EaseOutInTransition();

    public static const EASE_IN_BACK:ITweenTransition           = new EaseInBackTransition();
    public static const EASE_OUT_BACK:ITweenTransition          = new EaseOutBackTransition();
    public static const EASE_IN_OUT_BACK:ITweenTransition       = new EaseInOutBackTransition();
    public static const EASE_OUT_IN_BACK:ITweenTransition       = new EaseOutInBackTransition();

    public static const EASE_IN_ELASTIC:ITweenTransition        = new EaseInElasticTransition();
    public static const EASE_OUT_ELASTIC:ITweenTransition       = new EaseOutElasticTransition();
    public static const EASE_IN_OUT_ELASTIC:ITweenTransition    = new EaseInOutElasticTransition();
    public static const EASE_OUT_IN_ELASTIC:ITweenTransition    = new EaseOutInElasticTransition();

    public static const EASE_IN_BOUNCE:ITweenTransition         = new EaseInBounceTransition();
    public static const EASE_OUT_BOUNCE:ITweenTransition        = new EaseOutBounceTransition();
    public static const EASE_IN_OUT_BOUNCE:ITweenTransition     = new EaseInOutBounceTransition();
    public static const EASE_OUT_IN_BOUNCE:ITweenTransition     = new EaseOutInBounceTransition();

    private static var _transitions:Dictionary                  = null;

    public static function combine(startTransition:ITweenTransition, endTransition:ITweenTransition, v:Number):Number {
        if(v < 0.5) return 0.5 * startTransition.value(v * 2.0);
        else        return 0.5 * endTransition.value((v - 0.5) * 2.0) + 0.5;
    }

    public static function getByName(name:String):ITweenTransition {
        if(_transitions == null)
            initTransitions();

        return _transitions[name];
    }

    private static function initTransitions():void {
        _transitions = new Dictionary();

        _transitions[LINEAR.name] = LINEAR;

        _transitions[EASE_IN.name] = EASE_IN;
        _transitions[EASE_OUT.name] = EASE_OUT;
        _transitions[EASE_IN_OUT.name] = EASE_IN_OUT;
        _transitions[EASE_OUT_IN.name] = EASE_OUT_IN;

        _transitions[EASE_IN_BACK.name] = EASE_IN_BACK;
        _transitions[EASE_OUT_BACK.name] = EASE_OUT_BACK;
        _transitions[EASE_IN_OUT_BACK.name] = EASE_IN_OUT_BACK;
        _transitions[EASE_OUT_IN_BACK.name] = EASE_OUT_IN_BACK;

        _transitions[EASE_IN_ELASTIC.name] = EASE_IN_ELASTIC;
        _transitions[EASE_OUT_ELASTIC.name] = EASE_OUT_ELASTIC;
        _transitions[EASE_IN_OUT_ELASTIC.name] = EASE_IN_OUT_ELASTIC;
        _transitions[EASE_OUT_IN_ELASTIC.name] = EASE_OUT_IN_ELASTIC;

        _transitions[EASE_IN_BOUNCE.name] = EASE_IN_BOUNCE;
        _transitions[EASE_OUT_BOUNCE.name] = EASE_OUT_BOUNCE;
        _transitions[EASE_IN_OUT_BOUNCE.name] = EASE_IN_OUT_BOUNCE;
        _transitions[EASE_OUT_IN_BOUNCE.name] = EASE_OUT_IN_BOUNCE;
    }

    public function TweenTransitions() { throw new UninitializedError("this is a static class"); }
}
}
