/**
 * Created by njackson on 14/03/2014.
 */
package com.mands.di {
import br.slikland.leap.LeapSocket;
import br.slikland.leap.events.LeapEvent;

import flash.display.Sprite;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.geom.Point;

[SWF(backgroundColor="#000000", width="1280", height="720", frameRate="60")]
public class LeapTest extends Sprite {
    private var _hand:Hand;



    public function LeapTest() {

        var leapSocket:LeapSocket = new LeapSocket();
        leapSocket.addEventListener(Event.CONNECT, socketConnect);
        leapSocket.addEventListener(Event.CLOSE, close);
        leapSocket.addEventListener(IOErrorEvent.IO_ERROR, error);
        leapSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
        leapSocket.addEventListener(LeapEvent.DATA, leapData);

        leapSocket.connect("127.0.0.1", 6437);

        _hand = new Hand();
        _hand.visible = false;
        addChild(_hand);
    }

    private function socketConnect(event:Event):void {
        trace("Connected Leap");
    }

    private function leapData(event:LeapEvent):void
    {
        // Returns a Frame Object
        // Frame object: https://developer.leapmotion.com/documentation/api/class_leap_1_1_frame
        // LeapMotion Javascript tutorial: https://developer.leapmotion.com/documentation/guide/Sample_JavaScript_Tutorial
        if(event.data.hands.length > 0) {

            if(!_hand.visible)
                _hand.visible = true;

            var handPos = event.data.hands[0].palmPosition;
            var interactionBox = event.data.interactionBox;
            var pos:Point = leapToScene(interactionBox,handPos);

            _hand.x = pos.x;
            _hand.y = pos.y;

        } else {
            if(_hand.visible)
                _hand.visible = false;
        }


    }

    private function leapToScene(interactionBox,leapPos):Point {
        var pos:Point = new Point();

        var left = interactionBox.center[0] - interactionBox.size[0]/2;
        var top  = interactionBox.center[1] + interactionBox.size[1]/2;
        var x = leapPos[0] - left;
        var y = leapPos[1] - top;

        x = x / interactionBox.size[0];
        y = y / interactionBox.size[0];

        x = x * 1280;
        y = y * 720;

        pos.x = x;
        pos.y = -y;

        trace("left:" + left + " top:" + top + " x:" + x + " y:" + y);

        return pos;
    }

    private function error(event:ErrorEvent):void
    {
        trace("Error:", event.text);
    }

    private function close(event:Event):void
    {
        trace("Close");
    }

    private function connect(event:Event):void
    {
        trace("Connect")
    }
}
}
