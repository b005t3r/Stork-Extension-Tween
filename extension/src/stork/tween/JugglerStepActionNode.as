/**
 * User: booster
 * Date: 11/12/14
 * Time: 9:46
 */
package stork.tween {
import stork.game.GameActionNode;

public class JugglerStepActionNode extends GameActionNode {
    private var _juggler:JugglerNode;

    public function JugglerStepActionNode(juggler:JugglerNode, name:String = "JugglerStepAction") {
        if(juggler != null) super(juggler.actionPriority, name);
        else                throw new ArgumentError("'juggler' cannot be null");

        _juggler = juggler;
    }

    override protected function actionUpdated(dt:Number):void {
        _juggler.step(dt);
    }
}
}
