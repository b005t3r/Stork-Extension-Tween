package {

import flash.display.Sprite;

import stork.core.SceneNode;
import stork.starling.StarlingPlugin;
import stork.tween.JugglerNode;

[SWF(width="800", height="600", backgroundColor="#aaaaaa", frameRate="60")]
public class Main extends Sprite {
    public function Main() {
        var scene:SceneNode = new SceneNode();

        scene.registerPlugin(new StarlingPlugin(Root, this));

        scene.addNode(new JugglerNode());
        scene.addNode(new TouchHandlerNode(true)); // change for different satellite behaviour

        scene.start();
    }
}
}