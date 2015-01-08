/**
 * User: booster
 * Date: 06/02/14
 * Time: 9:33
 */
package stork.tween {
import stork.core.ContainerNode;
import stork.core.Node;
import stork.event.Event;
import stork.event.TimeFrameEvent;
import stork.event.TweenEvent;
import stork.transition.CompoundTransition;

public class TimeFrameNode extends ContainerNode {
    protected static const START_TIME:String        = "startTime";
    protected static const DURATION:String          = "duration";

    protected var _startTime:Number                 = 0;
    protected var _currentTime:Number               = 0;
    protected var _childTween:AbstractTweenNode     = null;
    protected var _childTweenDuration:Number        = 0;

    protected var _invalidatedEvent:TimeFrameEvent  = new TimeFrameEvent(TimeFrameEvent.INVALIDATED);
    protected var _durationDirty:Boolean            = true;

    public function TimeFrameNode(startTime:Number = 0, name:String = "TimeFrame") {
        super(name);

        _startTime = startTime;

        addEventListener(Event.ADDED_TO_PARENT, onChildAdded);
        addEventListener(Event.REMOVED_FROM_PARENT, onChildRemoved);
    }

    public function seek(totalTime:Number, suppressEvents:Boolean = true, parentTransition:CompoundTransition = null):Number {
        if(_childTween == null)
            return 0;

        if(_durationDirty)
            validateDuration();

        // current time goes from 0 fo Infinity (or parent Timeline's duration), so it must not be constrained
        //totalTime       = Math.min(_startTime + _childTweenDuration, Math.max(0, totalTime));
        _currentTime    = totalTime;

        _childTween.seek(_currentTime - _startTime - _childTween.delay, parentTransition);

        return _currentTime;
    }

    public function get childTween():AbstractTweenNode { return _childTween; }

    public function get currentTime():Number { return _currentTime; }

    public function get startTime():Number { return _startTime; }
    public function set startTime(value:Number):void {
        _startTime = value;

        dispatchEvent(_invalidatedEvent.reset());
    }

    public function get duration():Number {
        if(_durationDirty)
            validateDuration();

        return _childTweenDuration;
    }

    public function set duration(value:Number):void {
        if(_childTween == null)
            return;

        if(_durationDirty)
            validateDuration();

        var ratio:Number = value / _childTweenDuration;

        if(ratio < 1) {
            _childTween.duration    = (100.0 * ratio * _childTween.duration) / 100.0;
            _childTween.delay       = (100.0 * ratio * _childTween.delay) / 100.0;
            _childTween.repeatDelay = (100.0 * ratio * _childTween.repeatDelay) / 100.0;
        }
        else {
            _childTween.duration    = ratio * _childTween.duration;
            _childTween.delay       = ratio * _childTween.delay;
            _childTween.repeatDelay = ratio * _childTween.repeatDelay;
        }

        _durationDirty = true;

        dispatchEvent(_invalidatedEvent.reset());
    }

    public function advance(dt:Number, parentTransition:CompoundTransition):void {
        if(_childTween == null || dt == 0)
            return;

        if(_durationDirty)
            validateDuration();

        var previousTime:Number = _currentTime;

        _currentTime += dt;

        var endTime:Number = _startTime + _childTweenDuration;

        if((previousTime < _startTime && _currentTime < _startTime)
            || (previousTime > endTime && _currentTime > endTime))
            return;

        var reminder:Number = 0;

        if(dt > 0)  reminder = _currentTime - _startTime;
        else        reminder = _currentTime - endTime;

        if(Math.abs(reminder) < Math.abs(dt))
            _childTween.advance(reminder, parentTransition);
        else
            _childTween.advance(dt, parentTransition);
    }

    protected function onChildTweenInvalidated(event:TweenEvent):void {
        _durationDirty = true;

        dispatchEvent(_invalidatedEvent.reset());
    }

    protected function validateDuration():void {
        _childTweenDuration = _childTween != null ? TweenUtil.totalDuration(_childTween) : 0;

        _durationDirty = false;
    }

    protected function onChildAdded(event:Event):void {
        var child:Node = event.target as Node;

        if(child.parentNode != this) return;

        if(_childTween != null || child is AbstractTweenNode == false)
            throw new Error("TimeFrameComponent can only have one child AbstractTweenNode");

        _childTween = AbstractTweenNode(child);
        _childTween.addEventListener(TweenEvent.INVALIDATED, onChildTweenInvalidated);

        _durationDirty = true;

        dispatchEvent(_invalidatedEvent.reset());
    }

    protected function onChildRemoved(event:Event):void {
        var child:Node = event.target as Node;

        if(child.parentNode != this) return;

        if(_childTween != null) {
            _childTween.removeEventListener(TweenEvent.INVALIDATED, onChildTweenInvalidated);

            _childTween = null;

            _durationDirty = true;

            dispatchEvent(_invalidatedEvent.reset());
        }
    }
}
}
