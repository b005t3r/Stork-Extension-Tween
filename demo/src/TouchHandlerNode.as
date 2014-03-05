/**
 * User: booster
 * Date: 06/02/14
 * Time: 13:34
 */
package {
import flash.geom.Point;

import starling.display.Quad;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import stork.core.Node;
import stork.event.TweenEvent;
import stork.transition.ITweenTransition;
import stork.transition.TweenTransitions;
import stork.tween.JugglerNode;
import stork.tween.TimelineNode;
import stork.tween.TweenNode;

public class TouchHandlerNode extends Node {
    private var _root:Root;
    private var _quad:Quad;
    private var _juggler:JugglerNode;

    private var _timeline:TimelineNode;

    private var _simultaneous:Boolean;
    private var _transition:ITweenTransition;

    public function TouchHandlerNode(simultaneous:Boolean, transition:ITweenTransition) {
        super("TouchHandler");

        _simultaneous   = simultaneous;
        _transition     = transition;
    }

    [ObjectReference("@Root")]
    public function get root():Root { return _root; }
    public function set root(value:Root):void {
        if(_root != null)
            _root.removeEventListener(TouchEvent.TOUCH, onTouch);

        _root = value;

        if(_root != null)
            _root.addEventListener(TouchEvent.TOUCH, onTouch);
    }

    [StarlingReference("center")]
    public function get quad():Quad { return _quad; }
    public function set quad(value:Quad):void { _quad = value;}

    [GlobalReference("@stork.tween::JugglerNode")]
    public function get juggler():JugglerNode { return _juggler; }
    public function set juggler(value:JugglerNode):void { _juggler = value;}

    private function onTouch(event:TouchEvent):void {
        var touch:Touch = event.getTouch(_root, TouchPhase.ENDED);

        if(touch == null) return;

        var location:Point = touch.getLocation(_root);

        if(_timeline != null)
            _timeline.reset();

        _timeline = new TimelineNode(_transition);
        _timeline.repeatReversed = true;
        _timeline.repeatCount = 2;

        var tween:TweenNode;

        tween = new TweenNode(_quad, Math.random() * 0.5 + 0.25);
        tween.animateTo("x", location.x);
        tween.animateTo("y", location.y);
        _timeline.addTween(tween);

        for(var i:int = 0; i < Root.SATELLITE_COUNT; ++i) {
            var q:Quad = _root.getSateliteQuad(i);

            const twoPies:Number = 2 * Math.PI;
            var p:Point = Point.polar(120, i * (twoPies / Root.SATELLITE_COUNT));

            tween = new TweenNode(q, Math.random() * 0.5 + 0.25);
            tween.animateTo("x", location.x + p.x);
            tween.animateTo("y", location.y + p.y);

            if(_simultaneous) {
                _timeline.addTween(tween, Math.random() * 0.33);
            }
            else {
                _timeline.addTween(tween);
                tween.delay = Math.random() * 0.1;
            }
        }

        _juggler.addNode(_timeline);
    }
}
}
