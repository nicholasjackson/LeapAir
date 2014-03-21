/**
 * Created by njackson on 14/03/2014.
 */
package com.mands.di {
import Box2D.Collision.Shapes.b2CircleShape;
import Box2D.Collision.Shapes.b2PolygonShape;
import Box2D.Common.Math.b2Vec2;
import Box2D.Dynamics.Joints.b2MouseJoint;
import Box2D.Dynamics.Joints.b2MouseJointDef;
import Box2D.Dynamics.Joints.b2RopeJoint;
import Box2D.Dynamics.Joints.b2RopeJointDef;
import Box2D.Dynamics.b2Body;
import Box2D.Dynamics.b2BodyDef;
import Box2D.Dynamics.b2DebugDraw;
import Box2D.Dynamics.b2FixtureDef;
import Box2D.Dynamics.b2World;

import br.slikland.leap.LeapSocket;
import br.slikland.leap.events.LeapEvent;

import flash.display.Sprite;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.geom.Point;

[SWF(backgroundColor="#000000", width="1280", height="720", frameRate="60")]
public class LeapTest extends Sprite {
    private var _hand:Hand;
    private var _fingers:Vector.<Finger>;
    private var angularVelocity:Number = 1;
    private var world:b2World;

    public var doSleep:Boolean = false;
    public var steps:int = 300;
    public var frequency:int = 60;
    public var velocityIterations:int = 10;
    public var positionIterations:int = 10;
    public var warmStarting:Boolean = true;
    public var continuousPhysics:Boolean = false;
    private var timeStep:Number = 1.0 / frequency;

    private var WIDTH:int = 1280;
    private var HEIGHT:int = 720;
    private var PIXES_TO_METER:int = 30;

    private var STRING_LENGTH:int = 200;

    private var debugSprite:Sprite;
    private var _doll:RagDoll;
    private var mouseJoint:b2RopeJoint;
    private var _mouse:b2Body;

    public function LeapTest() {

        setupBox2D();

        createHand();
        setupLeap();

    }

    private function setupLeap():void {
        var leapSocket:LeapSocket = new LeapSocket();
        leapSocket.addEventListener(Event.CONNECT, socketConnect);
        leapSocket.addEventListener(Event.CLOSE, close);
        leapSocket.addEventListener(IOErrorEvent.IO_ERROR, error);
        leapSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
        leapSocket.addEventListener(LeapEvent.DATA, leapData);

        leapSocket.connect("127.0.0.1", 6437);
    }

    private function setupBox2D():void {
        world = new b2World(new b2Vec2(0,10), true);
        //world.SetWarmStarting(warmStarting);
       //world.SetContinuousPhysics(continuousPhysics);

        var envDef:b2BodyDef

        var groundBodyDef:b2BodyDef = new b2BodyDef();
        groundBodyDef.position.Set(
                (WIDTH/2) / PIXES_TO_METER,
                (HEIGHT/PIXES_TO_METER) - (20/PIXES_TO_METER));

        var groundBody:b2Body = world.CreateBody(groundBodyDef);

        var groundBox:b2PolygonShape = new b2PolygonShape();
        groundBox.SetAsBox((WIDTH/2) / PIXES_TO_METER,
                20/PIXES_TO_METER);

        var groundFixtureDef:b2FixtureDef = new b2FixtureDef();
        groundFixtureDef.shape = groundBox;
        groundFixtureDef.density = 1;
        groundFixtureDef.friction = 1;
        groundBody.CreateFixture(groundFixtureDef);

        var bodyDef:b2BodyDef = new b2BodyDef();
        bodyDef.type = b2Body.b2_dynamicBody;
        bodyDef.position.Set((WIDTH/2)/PIXES_TO_METER,4);
        var body:b2Body = world.CreateBody(bodyDef);

        var dynamicBox:b2PolygonShape = new b2PolygonShape();
        dynamicBox.SetAsBox(1,1);

        var fixtureDef:b2FixtureDef = new b2FixtureDef();
        fixtureDef.shape = dynamicBox;
        fixtureDef.density = 1;
        fixtureDef.friction = 0.3;

        body.CreateFixture(fixtureDef);

        debugSprite = new Sprite();
        addChild(debugSprite);

        var debugDraw:b2DebugDraw = new b2DebugDraw();
        debugDraw.SetSprite(debugSprite);
        debugDraw.SetDrawScale(PIXES_TO_METER);
        debugDraw.SetLineThickness(1.0);
        debugDraw.SetAlpha(1);
        debugDraw.SetFillAlpha(0.4);
        debugDraw.SetFlags(b2DebugDraw.e_shapeBit);
        world.SetDebugDraw(debugDraw);

        _doll = new RagDoll(world,new b2Vec2((WIDTH/2)/PIXES_TO_METER,0));

        this.addEventListener(Event.ENTER_FRAME, Box2DLooper);

        //stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseEvent);
        //stage.addEventListener(MouseEvent.MOUSE_UP, mouseDestroy);
    }

    private function mouseDestroy(event:MouseEvent):void {
        destroyMouse();
    }

    private function mouseEvent(event:MouseEvent):void {
        createMouse(new Point(mouseX,mouseY));
    }

    private function destroyMouse():void {
        if (mouseJoint) {
            world.DestroyBody(_mouse);
            world.DestroyJoint(mouseJoint);
            mouseJoint=null;
        }
    }

    private function createMouse(pos:Point):void {
        trace("CreateMouse");

        var circ:b2CircleShape = new b2CircleShape( 12.5 / PIXES_TO_METER );
        var fixtureDef:b2FixtureDef = new b2FixtureDef();
        var bd:b2BodyDef = new b2BodyDef();
        fixtureDef.shape = circ;
        fixtureDef.density = 1.0;
        fixtureDef.friction = 0.4;
        fixtureDef.restitution = 0.3;
        bd.position.Set(pos.x / PIXES_TO_METER, pos.y / PIXES_TO_METER);
        _mouse = world.CreateBody(bd);

        var ropeJointDef:b2RopeJointDef = new b2RopeJointDef();
        ropeJointDef.bodyA = _mouse;
        ropeJointDef.bodyB = _doll.Head;
        ropeJointDef.localAnchorA = new b2Vec2(0,0);
        ropeJointDef.localAnchorB = new b2Vec2(0,0);
        ropeJointDef.maxLength = 6;
        ropeJointDef.collideConnected = true;
        world.CreateJoint(ropeJointDef);

        mouseJoint=world.CreateJoint(ropeJointDef) as b2RopeJoint;
    }

    private function Box2DLooper(event:Event):void {
        var timeStep:Number = 1 / 30;
        var velocityIterations:int = 6;
        var positionIterations:int = 2;

        world.Step(timeStep,velocityIterations,positionIterations);
        world.ClearForces();
        world.DrawDebugData();

        if (mouseJoint) {
            var mouseXWorldPhys=_hand.x/PIXES_TO_METER;
            var mouseYWorldPhys=_hand.y/PIXES_TO_METER;
            var p2:b2Vec2=new b2Vec2(mouseXWorldPhys,mouseYWorldPhys);
            _mouse.SetPosition(p2);
        }

    }

    private function createHand() {
        _hand = new Hand();
        addChild(_hand);

        _fingers = new Vector.<Finger>();
        for(var f=0; f < 6;f++) {
            var _finger = new Finger();
            addChild(_finger);
            _fingers.push(_finger);
        }

    }

    private function socketConnect(event:Event):void {
        trace("Connected Leap");
    }

    private function leapData(event:LeapEvent):void
    {
        // Returns a Frame Object
        // Frame object: https://developer.leapmotion.com/documentation/api/class_leap_1_1_frame
        // LeapMotion Javascript tutorial: https://developer.leapmotion.com/documentation/guide/Sample_JavaScript_Tutorial
        if(event.data.hands != null && event.data.hands.length > 0) {

            if(!_hand.visible)
                _hand.visible = true;

            // do we have a mouse joint?


            var handPos = event.data.hands[0].palmPosition;
            var interactionBox = event.data.interactionBox;
            var pos:Point = leapToScene(interactionBox,handPos);

            var handID:Number =  event.data.hands[0].id;

            _hand.x = pos.x;
            _hand.y = pos.y;

            if(!mouseJoint)
                createMouse(pos);

           // check for fingers
           var numFingers:Number = event.data.pointables.length;

            for(var f=0; f < 6; f++) {
                _fingers[f].visible = false;
            }

           for(var f=0; f < numFingers; f++) {
               var finger = event.data.pointables[f];

               if(finger.id = handID && f < 6) {
                   var fingerPos = finger.stabilizedTipPosition;

                   var pos:Point = leapToScene(interactionBox,fingerPos);
                   _fingers[f].x = pos.x;
                   _fingers[f].y = pos.y;
                   _fingers[f].visible = true;
               }
           }

        } else {
            if(_hand.visible)
                _hand.visible = false;

            if(mouseJoint)
                destroyMouse();

            for(var f=0; f < numFingers; f++) {
                _fingers[f].visible = false;
            }
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
