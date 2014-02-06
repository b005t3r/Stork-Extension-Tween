/**
 * User: booster
 * Date: 06/02/14
 * Time: 13:22
 */
package {
import flash.geom.Point;

import starling.display.Quad;
import starling.display.StorkRoot;
import starling.events.Event;
import starling.utils.Color;

public class Root extends StorkRoot {
    public static const WIDTH:Number            = 800;
    public static const HEIGHT:Number           = 600;

    public static const SATELLITE_COUNT:int     = 36;

    public function Root() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    public function getSateliteQuad(i:int):Quad { return getChildAt(2 + i) as Quad; }

    private function onAddedToStage(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        var quad:Quad;

        quad = new Quad(WIDTH, HEIGHT);
        quad.alpha = 0;

        addChild(quad); // for capturing touches

        quad = new Quad(75, 75, Color.AQUA);
        quad.alignPivot();
        quad.x = WIDTH / 2; quad.y = HEIGHT / 2;
        quad.name = "center";

        addChild(quad);

        var colors:Array = [Color.BLUE, Color.FUCHSIA, Color.GRAY, Color.GREEN, Color.LIME, Color.MAROON, Color.NAVY, Color.OLIVE, Color.PURPLE, Color.RED];

        for(var i:int = 0; i < SATELLITE_COUNT; ++i) {
            quad = new Quad(15, 15, colors[int(Math.random() * colors.length)]);
            quad.alignPivot();

            const twoPies:Number = 2 * Math.PI;
            var p:Point = Point.polar(120, i * (twoPies / SATELLITE_COUNT));

            quad.x = WIDTH / 2 + p.x; quad.y = HEIGHT / 2 + p.y;

            addChild(quad);
        }
    }
}
}
