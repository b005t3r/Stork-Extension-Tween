/**
 * User: booster
 * Date: 06/02/14
 * Time: 11:13
 */
package stork.tween {
import stork.core.Node;
import stork.event.Event;
import stork.event.TimeFrameEvent;
import stork.transition.CompoundTransition;
import stork.transition.ITweenTransition;
import stork.transition.TweenTransitions;

public class TimelineNode extends AbstractTweenNode {
    private static var _tweenNodes:Vector.<Node>            = new <Node>[];

    protected var _started:Boolean                          = false;
    protected var _paused:Boolean                           = false;
    protected var _prevProgress:Number                      = 0;
    protected var _sortedTimeFrames:Vector.<TimeFrameNode>  = null; // initialized on start

    protected var _durationDirty:Boolean                    = true;

    public function TimelineNode(transition:ITweenTransition = null, name:String = "Timeline") {
        super(0, transition, name);

        addEventListener(Event.ADDED_TO_PARENT, onChildAdded);
        addEventListener(Event.REMOVED_FROM_PARENT, onChildRemoved);
    }

    public function addTween(tween:AbstractTweenNode, startTime:Number = Number.NaN):void {
        if(started)
            throw new Error("you can't add new tweens to an already started timeline");

        var timeFrame:TimeFrameNode = new TimeFrameNode(/* isNaN check */ startTime != startTime ? duration : startTime);

        timeFrame.addNode(tween);
        addNode(timeFrame); // invalidates Timeline's duration
    }

    public function get paused():Boolean { return _paused; }
    public function set paused(value:Boolean):void { _paused = value; }

    override public function reset(duration:Number = 0, transition:ITweenTransition = null):void {
        _started            = false;
        _paused             = false;
        _prevProgress       = 0;
        _sortedTimeFrames   = null;

        super.reset(duration, transition);
    }

    override public function get duration():Number {
        if(_durationDirty)
            validateDuration();

        return _duration;
    }

    override public function set duration(value:Number):void {
        if(_durationDirty)
            validateDuration();

        var ratio:Number = value / _duration;

        var count:int = nodeCount;
        for(var i:int = 0; i < count; ++i) {
            var timeFrame:TimeFrameNode = getNodeAt(i) as TimeFrameNode;

            if(ratio < 1) {
                timeFrame.duration  = (100.0 * ratio * timeFrame.duration) / 100.0;
                timeFrame.startTime = (100.0 * ratio * timeFrame.startTime) / 100.0;
            }
            else {
                timeFrame.duration  = ratio * timeFrame.duration;
                timeFrame.startTime = ratio * timeFrame.startTime;
            }
        }

        dispatchEvent(_invalidatedEvent.reset());
    }

    override public function advance(dt:Number, parentTransition:CompoundTransition):void {
        if(_paused)
            return;

        if(_durationDirty)
            validateDuration();

        _prevProgress = _progress;

        super.advance(dt, parentTransition);
    }

    override public function seek(totalTime:Number, suppressEvents:Boolean = true, parentTransition:CompoundTransition = null):Number {
        totalTime = Math.min(TweenUtil.totalDuration(this), Math.max(totalTime, -_delay));

        var prevTotalTime:Number    = this.totalTime;
        var dt:Number               = totalTime - prevTotalTime;

        // why was this ever necessary?
        //var rev:Boolean = _repeatReversed && (_currentCycle % 2 == 1);
        //rev             = dt < 0 ? ! rev : rev;
        //_sortedTimeFrames = sortedTimeFrames(! rev);

        if(parentTransition == null)
            parentTransition = new CompoundTransition();

        var oldPaused:Boolean = _paused;
        _paused = false;

        // seek always works forward, so reverse dt and advance will reverse it again
        if(_reversed)
            dt = -dt;

        advance(dt, parentTransition);

        _paused = oldPaused;

        return _cycleTime;
    }

    override public function get started():Boolean { return _started;}

    protected function sortedTimeFrames(fromStart:Boolean = true):Vector.<TimeFrameNode> {
        var vec:Vector.<TimeFrameNode> = new <TimeFrameNode>[];

        var count:int = nodeCount;
        for(var i:int = 0; i < count; i++) {
            var timeFrame:TimeFrameNode = getNodeAt(i) as TimeFrameNode;
            vec.push(timeFrame);
        }

        vec.sort(function compare(x:TimeFrameNode, y:TimeFrameNode):Number {
            // should descending compare finish times?
            return fromStart
                ? x.startTime - y.startTime
                : (y.startTime + y.duration) - (x.startTime + x.duration);
        });

        return vec;
    }

    override protected function isReadyToStart():Boolean { return true; }
    override protected function animationStarted(reversed:Boolean):void {
        // validate all tween on start
        _tweenNodes.length = 0;
        getNodesByClass(TweenNode, _tweenNodes, true);

        var count:int = _tweenNodes.length;
        for(var i:int = 0; i < count; i++) {
            var tween:TweenNode = _tweenNodes[i] as TweenNode;

            tween.validateProperties();
        }

        _tweenNodes.length = 0;

        _started = true;

        animationRepeated(reversed);
    }

    override protected function animationUpdated(parentTransition:CompoundTransition):void {
        var dt:Number = _duration * _progress - _duration * _prevProgress;

        if(dt == 0)
            return;

        var count:int = _sortedTimeFrames.length;
        for (var i:int = 0; i < count; i++) {
            var timeFrame:TimeFrameNode = _sortedTimeFrames[i];

            var diff:Number = timeFrame.startTime + timeFrame.duration - timeFrame.currentTime;

            if(_progress == 1 && dt > 0)
                timeFrame.advance(Math.ceil(diff * 1000000) / 1000000, parentTransition); // to solve floating-point accuracy problems
            else if(_progress == 0 && dt < 0)
                timeFrame.advance(Math.floor(-timeFrame.currentTime * 1000000) / 1000000, parentTransition); // to solve floating-point accuracy problems
            else
                timeFrame.advance(dt, parentTransition);
        }
    }

    override protected function animationRepeated(reversed:Boolean):void {
        var rev:Boolean = _repeatReversed && (_currentCycle % 2 == 1);
        rev             = reversed ? ! rev : rev;

        _sortedTimeFrames = sortedTimeFrames(! rev);

        for (var i:int = _sortedTimeFrames.length - 1; i >= 0; i--) {
            var timeFrame:TimeFrameNode = _sortedTimeFrames[i];

            timeFrame.seek(! rev ? 0 : _duration);
        }
    }

    override protected function animationFinished():void {
        _started = false;

        _sortedTimeFrames = null;
    }

    override protected function calculateProgress(time:Number, trans:ITweenTransition):Number {
        // it's this timeline's progress, so don't add your own transition - it will be applied to leaf-tweens anyway

        return super.calculateProgress(time, TweenTransitions.LINEAR);
    }

    protected function onChildInvalidated(event:TimeFrameEvent):void {
        _durationDirty = true;

        dispatchEvent(_invalidatedEvent.reset());
    }

    protected function onChildAdded(event:Event):void {
        var child:Node = event.target as Node;

        if(child.parentNode != this) return;

        if(child is TimeFrameNode == false)
            throw new TypeError("all children of TimelineNode has to be TimeFrameNodes");

        var timeFrame:TimeFrameNode = TimeFrameNode(child);

        timeFrame.addEventListener(TimeFrameEvent.INVALIDATED, onChildInvalidated);

        _durationDirty = true;

        dispatchEvent(_invalidatedEvent.reset());
    }

    protected function onChildRemoved(event:Event):void {
        var child:Node = event.target as Node;

        if(child.parentNode != this) return;

        var timeFrame:TimeFrameNode = child as TimeFrameNode;

        timeFrame.removeEventListener(TimeFrameEvent.INVALIDATED, onChildInvalidated);

        _durationDirty = true;

        dispatchEvent(_invalidatedEvent.reset());
    }

    protected function validateDuration():void {
        _duration = 0;

        var count:int = nodeCount;
        for(var i:int = 0; i < count; ++i) {
            var timeFrame:TimeFrameNode = getNodeAt(i) as TimeFrameNode;

            _duration = Math.max(_duration, timeFrame.startTime + timeFrame.duration);
        }

        _durationDirty = false;
    }
}
}
