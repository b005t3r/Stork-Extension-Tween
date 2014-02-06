/**
 * User: booster
 * Date: 9/12/13
 * Time: 10:12
 */

package stork.transition {

public class CompoundTransition implements ITweenTransition {
    protected var _transitions:Vector.<ITweenTransition> = new <ITweenTransition>[];

    public function CompoundTransition() {}

    public function get name():String { return "Compound Transition"; }

    public function value(v:Number):Number {
        var count:int       = _transitions.length;
        var ratio:Number    = 1; // how much 'away' from v is the result, 1 means result is equal to v
        var div:Number      = v > 0 ? v : 0.000000000001;

        for(var i:int = 0; i < count; i++) {
            var trans:ITweenTransition = _transitions[i];

            if(trans == null || trans is LinearTransition)
                continue;

            ratio *= trans.value(v) / div;
        }

        return v * ratio;
    }

    public function pushTransition(transition:ITweenTransition):void {
        _transitions[_transitions.length] = transition;
    }

    public function popTransition():ITweenTransition {
        var retVal:ITweenTransition = _transitions[_transitions.length - 1];
        _transitions.length--;

        return retVal;
    }

    public function removeAllTransitions():void {
        _transitions.length = 0;
    }
}
}
