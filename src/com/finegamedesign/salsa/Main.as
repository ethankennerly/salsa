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

    public dynamic class Main extends Sprite
    {
        internal var keyMouse:KeyMouse;
        private var midi:Midi;

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
            midi.play(midi.salsa, 184 * 2);
            scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            keyMouse = new KeyMouse();
            keyMouse.listen(stage);
        }
    }
}
