/**
 * User: booster
 * Date: 06/02/14
 * Time: 9:06
 */
package stork.tween {
import stork.core.ContainerNode;
import stork.event.Event;
import stork.event.SceneStepEvent;
import stork.transition.CompoundTransition;

public class JugglerNode extends ContainerNode {
    private static var _compoundTransition:CompoundTransition = new CompoundTransition();

    private var _timeScale:Number   = 1.0;
    private var _paused:Boolean     = false;

    public function JugglerNode(name:String = "JugglerNode") {
        super(name);

        addEventListener(Event.ADDED_TO_SCENE, onAddedToScene);
        addEventListener(Event.REMOVED_FROM_SCENE, onRemovedFromScene);
    }

    /** Ratio used to scale each time interval passed to children (may be negative). @default 1.0 */
    public function set timeScale(value:Number):void { _timeScale = value; }
    public function get timeScale():Number { return _timeScale; }

    /** Is this Juggler currently paused or not. @default false */
    public function set paused(value:Boolean):void { _paused = value; }
    public function get paused():Boolean { return _paused; }

    private function onAddedToScene(event:Event):void { sceneNode.addEventListener(SceneStepEvent.STEP, onStep); }
    private function onRemovedFromScene(event:Event):void { sceneNode.removeEventListener(SceneStepEvent.STEP, onStep); }

    private function onStep(event:SceneStepEvent):void {
        if(_paused) return;

        var scaledDt:Number = event.dt * _timeScale;

        var count:int = nodeCount;
        for(var i:int = 0; i < count; ++i) {
            var tween:AbstractTweenNode = getNodeAt(i) as AbstractTweenNode;

            if(tween == null)
                continue;

            _compoundTransition.removeAllTransitions();
            tween.advance(scaledDt, _compoundTransition);
        }
    }
}
}