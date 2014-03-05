/**
 * User: booster
 * Date: 06/02/14
 * Time: 9:23
 */
package stork.tween {
import stork.transition.CompoundTransition;
import stork.transition.ITweenTransition;

public class TweenNode extends AbstractTweenNode {
    protected var _target:Object                = null;

    protected var _started:Boolean              = false;
    protected var _propertiesDirty:Boolean      = true;

    protected var _properties:Vector.<String>   = new Vector.<String>();
    protected var _startValues:Vector.<Number>  = new Vector.<Number>();
    protected var _endValues:Vector.<Number>    = new Vector.<Number>();

    public function TweenNode(target:Object = null, duration:Number = 1, transition:ITweenTransition = null, name:String = "TweenNode") {
        super(duration, transition, name);

        this.target = target;
    }

    /** The target object that is animated. */
    public function get target():Object { return _target; }
    public function set target(value:Object):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _target = value;
    }

    /** Animate given property from current to given value. */
    public function animateTo(propertyName:String, value:Number):void {
        animateFromTo(propertyName, Number.NaN, value);
    }

    /** Animate given property from given to current value. */
    public function animateFrom(propertyName:String, value:Number):void {
        animateFromTo(propertyName, value, Number.NaN);
    }

    /** Animate given property from and to given value. */
    public function animateFromTo(propertyName:String, from:Number, to:Number):void {
        var index:int = _properties.indexOf(propertyName);

        if(index == -1) {
            _properties.push(propertyName);
            _startValues.push(from);
            _endValues.push(to);
        }
        else {
            _startValues[index] = from;
            _endValues[index]   = to;
        }

        _propertiesDirty = true;
    }

    /** Names of the properties animated using this tween. */
    public function get propertyNames():Vector.<String> { return _properties; }

    /** Start value for given property (or NaN if not set). */
    public function valueFrom(propertyName:String):Number {
        var index:int = _properties.indexOf(propertyName);

        return index == -1
            ? Number.NaN
            : _startValues[index]
            ;
    }

    /** End value for given property (or NaN if not set). */
    public function valueTo(propertyName:String):Number {
        var index:int = _properties.indexOf(propertyName);

        return index == -1
            ? Number.NaN
            : _endValues[index]
            ;
    }

    /** Fills in missing start and end values. */
    public function validateProperties():void {
        var numProperties:int = _properties.length;
        for(var i:int = 0; i < numProperties; ++i) {
            if(_startValues[i] != _startValues[i]) // isNaN check - "isNaN" causes allocation!
                _startValues[i] = _target[_properties[i]] as Number;

            if(_endValues[i] != _endValues[i]) // isNaN check - "isNaN" causes allocation!
                _endValues[i] = _target[_properties[i]] as Number;
        }

        _propertiesDirty = false;
    }

    override public function reset(duration:Number = 1, transition:ITweenTransition = null):void {
        _started            = false;
        _target             = null;
        _properties.length  = 0;
        _startValues.length = 0;
        _endValues.length   = 0;

        super.reset(duration, transition);
    }

    override public function get started():Boolean { return _started; }

    override protected function isReadyToStart():Boolean {
        return _target != null;
    }

    override protected function animationStarted(reversed:Boolean):void {
        _started = true;

        // setup start and end values
        if(_propertiesDirty)
            validateProperties();
    }

    override protected function animationUpdated(parentTransition:CompoundTransition):void {
        var numProperties:int = _properties.length;

        for(var i:int = 0; i < numProperties; ++i) {
            var startValue:Number   = _startValues[i];
            var endValue:Number     = _endValues[i];
            var delta:Number        = endValue - startValue;
            var currentValue:Number = startValue + _progress * delta;

            if(_roundToInt)
                currentValue = Math.round(currentValue);

            _target[_properties[i]] = currentValue;
        }
    }

    override protected function animationFinished():void {
        _started = false;

        super.animationFinished();
    }
}
}
