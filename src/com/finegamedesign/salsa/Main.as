package com.finegamedesign.salsa
{
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.utils.getTimer;

    import org.flixel.system.input.KeyMouse;

    public final dynamic class Main extends Sprite
    {
        internal var keyMouse:KeyMouse;
        private var dancer:Dancer;
        private var midi:Midi;
        private var scene:Scene;

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
            dancer = new Dancer(scene.diagram, midi.smfData.bpm);
            keyMouse = new KeyMouse();
            keyMouse.listen(stage);
            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            addChild(scene);
        }

        private function update(e:Event):void
        {
            dancer.update(midi.driver.position);
        }
    }
}
