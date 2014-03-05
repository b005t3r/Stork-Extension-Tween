/**
 * User: booster
 * Date: 06/02/14
 * Time: 8:58
 */
package stork.tween {
import stork.core.ContainerNode;
import stork.event.TweenEvent;
import stork.transition.CompoundTransition;
import stork.transition.ITweenTransition;
import stork.transition.TweenTransitions;

public class AbstractTweenNode extends ContainerNode {
    protected var _transition:ITweenTransition      = null; // null means linear

    protected var _duration:Number                  = 1;
    protected var _cycleTime:Number                 = 0;
    protected var _progress:Number                  = 0;
    protected var _delay:Number                     = 0;
    protected var _roundToInt:Boolean               = false;
    protected var _repeatCount:int                  = 1;
    protected var _repeatDelay:Number               = 0;
    protected var _repeatReversed:Boolean           = false;
    protected var _reversed:Boolean                 = false;
    protected var _autoReset:Boolean                = true;
    protected var _currentCycle:int                 = 0;

    // cached events
    protected var _startedEvent:TweenEvent          = new TweenEvent(TweenEvent.STARTED);
    protected var _finishedEvent:TweenEvent         = new TweenEvent(TweenEvent.FINISHED);
    protected var _advancedEvent:TweenEvent         = new TweenEvent(TweenEvent.ADVANCED);
    protected var _repeatedEvent:TweenEvent         = new TweenEvent(TweenEvent.REPEATED);

    protected var _invalidatedEvent:TweenEvent      = new TweenEvent(TweenEvent.INVALIDATED);

    public function AbstractTweenNode(duration:Number = 1, transition:ITweenTransition = null, name:String   = "AbstractTweenNode") {
        super(name);

        reset(duration, transition);
    }

    // abstract methods

    public function get started():Boolean { throw new UninitializedError("abstract method"); }

    /** The tween will not start, unless this method returns true. */
    protected function isReadyToStart():Boolean { throw new UninitializedError("abstract method"); }

    /** Called before the animation has started. After this method returns, all subsequent calls to 'started' have to return true. Abstract. */
    protected function animationStarted(reversed:Boolean):void { throw new UninitializedError("abstract method"); }

    /** Called each frame, after internal members have been updated. Abstract. */
    protected function animationUpdated(parentTransition:CompoundTransition):void { throw new UninitializedError("abstract method"); }

    /** Called each repetition except last, after internal members have been updated. */
    protected function animationRepeated(reversed:Boolean):void {  }

    /** Called on last repetition, after internal members have been updated. After this method returns, all subsequent calls to 'started' have to return false. Abstract. */
    protected function animationFinished():void {
        // reset only if added to JugglerNode, so no tween will be removed from timelines, etc.
        if(_autoReset && parentNode is JugglerNode)
            reset();
    }

    // implemented methods

    public function advance(dt:Number, parentTransition:CompoundTransition):void {
        if(dt == 0)
            return;

        if(! started && ! isReadyToStart())
            return;

        if(_reversed)
            dt = -dt;

        // this tween has finished its execution on the previous advance() call
        if(isFinished(dt))
            return;

        if(! started) {
            animationStarted(dt < 0);

            if(! started)
                throw new UninitializedError("property 'started' not set to 'true' in the 'animationStarted()' handler");

            dispatchEvent(_startedEvent.reset());
        }

        var nextCycle:int       = _currentCycle;
        var currentDelay:Number = currentCycleDelay;
        var previousTime:Number = _cycleTime;
        _cycleTime             += dt;

        // update cycle counter
        if(previousTime < _duration && _cycleTime >= _duration)
            nextCycle++;
        else if(previousTime > -currentDelay && _cycleTime <= -currentDelay)
            nextCycle--;

        // normalize current time between [-delay; duration] or [-repeatDelay; duration] depending on current cycle
        normalizeCurrentTime();

        // the delay is not over yet
        if(_cycleTime <= 0 && previousTime <= 0 && _currentCycle == nextCycle)
            return;

        parentTransition.pushTransition(_transition);
        {
            _progress = calculateProgress(_cycleTime, parentTransition);

            animationUpdated(parentTransition);
        }
        parentTransition.popTransition();

        dispatchEvent(_advancedEvent.reset());

        // advance this tween
        _currentCycle = nextCycle;

        var restTime:Number, carryOverTime:Number = 0;

        // update current time
        // 1. going forward
        if(previousTime < _duration && _cycleTime >= _duration) {
            restTime        = _duration - previousTime;
            carryOverTime   = dt > restTime ? dt - restTime : 0.0;

            if(_repeatCount == 0 || _currentCycle < _repeatCount) {
                _cycleTime  = -currentCycleDelay; // next cycle's delay
                parentTransition.pushTransition(_transition);
                {
                    _progress   = calculateProgress(_cycleTime, parentTransition);
                }
                parentTransition.popTransition();

                animationRepeated(false);

                dispatchEvent(_repeatedEvent.reset());
            }
            else {
                _currentCycle = _repeatCount - 1;

                animationFinished();

                if(started)
                    throw new UninitializedError("property 'started' not set to 'false' in the 'animationFinished()' handler");

                dispatchEvent(_finishedEvent.reset());

                return;
            }
        }
        // 2. going backward - use next cycle's delay
        else if(previousTime > -currentDelay && _cycleTime <= -currentDelay) {
            restTime        = -currentDelay - previousTime;
            carryOverTime   = dt < restTime ? dt - restTime : 0.0;

            if(_repeatCount == 0 || _currentCycle >= 0) {
                _cycleTime  = _duration;
                parentTransition.pushTransition(_transition);
                {
                    _progress   = calculateProgress(_cycleTime, parentTransition);
                }
                parentTransition.popTransition();

                animationRepeated(true);

                dispatchEvent(_repeatedEvent.reset());
            }
            else {
                _currentCycle = 0;

                animationFinished();

                if(started)
                    throw new UninitializedError("property 'started' not set to 'false' in the 'animationFinished()' handler");

                dispatchEvent(_finishedEvent.reset());

                return;
            }
        }

        // simulate another repetition if necessary
        if(carryOverTime != 0)
        // because carryOverTime will be reversed by advance() call
            advance(_reversed ? -carryOverTime : carryOverTime, parentTransition);
    }

    protected function isFinished(dt:Number):Boolean {
        return (_cycleTime == _duration && _cycleTime + dt > _duration)
            || (_cycleTime == -currentCycleDelay && _cycleTime + dt < -currentCycleDelay);
    }

    protected function normalizeCurrentTime():void {
        if(_cycleTime < -currentCycleDelay)  _cycleTime = -currentCycleDelay;
        else if(_cycleTime > _duration)      _cycleTime = _duration;
    }

    public function reset(duration:Number = 1, transition:ITweenTransition = null):void {
        _cycleTime      = 0.0;
        _duration       = Math.max(0.0001, duration);
        _progress       = 0.0;
        _delay          = 0.0;
        _repeatDelay    = 0.0;
        _roundToInt     = false;
        _repeatReversed = false;
        _reversed       = false;
        _repeatCount    = 1;
        _currentCycle   = 0;
        _transition     = transition != null ? transition : TweenTransitions.LINEAR;

        removeEventListeners();
        removeFromParent();
    }

    public function seek(totalTime:Number, suppressEvents:Boolean = true, parentTransition:CompoundTransition = null):Number {
        /*
         var time:Number = seekImpl(totalTime, suppressEvents, parentTransition);

         animationUpdated(parentTransition);

         return time;
         */

        totalTime = Math.min(TweenUtil.totalDuration(this), Math.max(totalTime, -_delay));

        if(parentTransition == null)
            parentTransition = new CompoundTransition();

        advance(totalTime, parentTransition);

        return _cycleTime;
    }

    public function get transition():ITweenTransition { return _transition; }
    public function set transition(value:ITweenTransition):void {
        if(value == null)
            throw new ArgumentError("transition may not be null");

        if(started)
            throw new Error("tween already started, call reset() first");

        _transition = value;
    }

    public function get transitionName():String { return transition != null ? transition.name : TweenTransitions.LINEAR.name; }
    public function set transitionName(value:String):void {
        transition = TweenTransitions.getByName(value);
    }

    public function get duration():Number { return _duration; }
    public function set duration(value:Number):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _duration = value > 0 ? value : 0.0001;

        dispatchEvent(_invalidatedEvent.reset());
    }

    public function get cycleTime():Number { return _cycleTime; }

    public function get totalTime():Number {
        if(_currentCycle == 0)
            return _delay + _cycleTime;
        else
            return _delay + _currentCycle * (_duration + _repeatDelay) + _cycleTime;
    }

    public function get progress():Number { return _progress; }

    public function get delay():Number { return _delay; }
    public function set delay(value:Number):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _cycleTime   += _delay - value;
        _delay        = value > 0 ? value : 0;

        dispatchEvent(_invalidatedEvent.reset());
    }

    public function get repeatCount():int { return _repeatCount; }
    public function set repeatCount(value:int):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _repeatCount = value > 0 ? value : 0;

        dispatchEvent(_invalidatedEvent.reset());
    }

    public function get repeatDelay():Number { return _repeatDelay; }
    public function set repeatDelay(value:Number):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _repeatDelay = value > 0 ? value : 0;

        dispatchEvent(_invalidatedEvent.reset());
    }

    public function get currentCycleDelay():Number {
        if(_currentCycle == 0)  return _delay;
        else                    return _repeatDelay;
    }

    public function get repeatReversed():Boolean { return _repeatReversed; }
    public function set repeatReversed(value:Boolean):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _repeatReversed = value;
    }

    public function get reversed():Boolean { return _reversed; }
    public function set reversed(value:Boolean):void { _reversed = value; }

    public function get autoReset():Boolean { return _autoReset; }
    public function set autoReset(value:Boolean):void { _autoReset = value; }

    public function get roundToInt():Boolean { return _roundToInt; }
    public function set roundToInt(value:Boolean):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _roundToInt = value;
    }

    protected function calculateProgress(time:Number, trans:ITweenTransition):Number {
        var ratio:Number    = time / _duration;
        var revRep:Boolean  = _repeatReversed && (_currentCycle % 2 == 1);
        //revRep              = _reversed ? !revRep : revRep;

        if(ratio < 0)       ratio = 0;
        else if(ratio > 1)  ratio = 1;

        return revRep
            ? trans.value(1.0 - ratio)
            : trans.value(ratio)
            ;
    }

    protected function seekImpl(totalTime:Number, suppressEvents:Boolean, parentTransition:CompoundTransition):Number {
        totalTime       = Math.min(TweenUtil.totalDuration(this), Math.max(totalTime, -_delay));
        _cycleTime      = totalTime;
        _currentCycle   = 0;

        // normalize time for the current repetition and find the current cycle
        if(_cycleTime > _duration) {
            var repeatTime:Number   = _repeatDelay + _duration;
            var cycles:Number       = _cycleTime / repeatTime;
            var reminder:Number     = _cycleTime % repeatTime;

            _currentCycle           = Math.floor(cycles); // current cycle index, starting from 0
            _cycleTime       = reminder - _repeatDelay;

            if(_currentCycle == _repeatCount) {
                _currentCycle--;
                _cycleTime = _duration;
            }
        }

        if(parentTransition == null)
            parentTransition = new CompoundTransition();

        parentTransition.pushTransition(_transition);
        _progress = calculateProgress(_cycleTime, parentTransition);
        parentTransition.popTransition();

        return _cycleTime;
    }
}
}
