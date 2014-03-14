/**
 * Created by njackson on 14/03/2014.
 */
package com.mands.di {
import flash.display.Sprite;
import flash.events.Event;

public class Hand extends Sprite {
    public function Hand() {

        addEventListener(Event.ADDED_TO_STAGE, init);

    }

    private function init(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE,init);

        graphics.beginFill(0xFFFFFF);
        graphics.drawCircle(0,0,20);
        graphics.endFill();
    }
}
}
