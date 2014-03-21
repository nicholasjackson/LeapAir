/**
 * Created by njackson on 14/03/2014.
 */
package com.mands.di {
import flash.display.Sprite;
import flash.events.Event;

public class Finger extends Sprite {
    public function Finger() {

        addEventListener(Event.ADDED_TO_STAGE, init);

    }

    private function init(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE,init);

        graphics.beginFill(0xFFFF00);
        graphics.drawCircle(0,0,10);
        graphics.endFill();

        visible = false;
    }
}
}
