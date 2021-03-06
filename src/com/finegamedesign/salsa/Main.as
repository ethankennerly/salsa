package com.finegamedesign.salsa
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.getTimer;

    import org.flixel.system.input.KeyMouse;

    public final dynamic class Main extends Sprite
    {
        internal var keyMouse:KeyMouse;
        private var dancer:Dancer;
        private var midi:Midi;
        private var scene:Scene;
        private var selectedDiagram:MovieClip;

        public function Main()
        {
            if (stage) {
                init(null);
            }
            else {
                addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
            }
        }
        
        public function init(event:Event=null):void
        {
            midi = new Midi();
            midi.play(midi.salsaBytes);
            scene = new Scene();
            scene.bone.mouseChildren = false;
            scene.bone.mouseEnabled = false;
            scene.step.mouseChildren = false;
            scene.step.mouseEnabled = false;
            scene.togglePlay.addEventListener(MouseEvent.CLICK, midi.togglePlay, false, 0, true);
            scene.bpmDown.addEventListener(MouseEvent.CLICK, bpmDown, false, 0, true);
            scene.bpmUp.addEventListener(MouseEvent.CLICK, bpmUp, false, 0, true);
            scene.bpmText.text = midi.bpm.toString();
            scene.sequence.addItem({label: "BasicStep", diagram: new BasicStep()});
            scene.sequence.addItem({label: "LeftTurn", diagram: new LeftTurn()});
            scene.sequence.addItem({label: "RightTurn", diagram: new RightTurn()});
            scene.sequence.addEventListener(Event.CHANGE, selectSequence, false, 0, true);
            scene.sequence.selectedIndex = 0;
            dancer = new Dancer(scene.bone.diagram, midi.smfData.bpm,
                stage.frameRate);
            keyMouse = new KeyMouse();
            keyMouse.listen(stage);
            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            bpmAdjust(midi.smfData.bpm * 0.5);
            addChild(scene);
        }

        private function bpmDown(event:MouseEvent):void
        {
            bpmAdjust(midi.bpm - 10);
            event.stopPropagation();
        }

        private function bpmUp(event:MouseEvent):void
        {
            bpmAdjust(midi.bpm + 10);
            event.stopPropagation();
        }

        private function bpmAdjust(bpm:int):void
        {
            midi.bpm = bpm;
            dancer.bpm = bpm;
        }

        private function selectSequence(event:Event):void
        {
            selectedDiagram = event.currentTarget.selectedItem.diagram;
            event.stopPropagation();
        }

        private function setSequence(diagram:MovieClip):void
        {
            replace(scene.bone.diagram, diagram);
            diagram.gotoAndStop(scene.bone.diagram.currentFrame);
            diagram.left.txt.text = scene.bone.diagram.left.txt.text;
            diagram.right.txt.text = scene.bone.diagram.right.txt.text;
            scene.bone.diagram = diagram;
            dancer = new Dancer(scene.bone.diagram, midi.bpm,
                stage.frameRate);
        }

        /**
         * Does not change position to avoid breaking animation.
         */
        private function replace(previous:DisplayObject, current:DisplayObject)
        {
            previous.parent.addChild(current);
            previous.parent.swapChildren(previous, current);
            previous.parent.removeChild(previous);
        }

        private function update(e:Event):void
        {
            var now:int = midi.driver.position;
            keyMouse.update();
            updateStep(now);
            var nextBeat:int = dancer.update(now);
            if (7 == nextBeat && null != selectedDiagram) {
                setSequence(selectedDiagram);
                selectedDiagram = null;
            }
            midi.update();
            scene.bpmText.text = midi.bpm.toString();
        }

        private function updateStep(milliseconds:int):void
        {
            if (keyMouse.justPressed("MOUSE")) {
                mousePoint.x = Math.round(keyMouse.target.mouseX);
                mousePoint.y = Math.round(keyMouse.target.mouseY);
                if (mousePoint.y < 100) {
                    return;
                }
                var isOnBeat:Boolean = dancer.isOnBeat(milliseconds);
                var label:String = isOnBeat ? "onbeat" : "offbeat";
                scene.step.gotoAndPlay(label);
                scene.step.x = mousePoint.x;
                scene.step.y = mousePoint.y;
                scene.step.foot.txt.text = dancer.getBeatText(milliseconds, isOnBeat);
                stepDistance(milliseconds, mousePoint);
            }
        }

        private var mousePoint:Point = new Point();
        private function stepDistance(milliseconds, mousePoint:Point):void
        {
            var label:String = dancer.isNear(milliseconds, mousePoint) ? "near" : "none";
            scene.step.distance.gotoAndPlay(label);
        }
    }
}
