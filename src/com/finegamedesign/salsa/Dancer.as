package com.finegamedesign.salsa
{
    import flash.display.MovieClip;
    import flash.utils.getTimer;

    internal final class Dancer
    {
        private var beat:int;
        private var beatLength:int;
        private var bpm:int;
        private var diagram:MovieClip;
        private var halfFrameMilliseconds:Number;
        private var millisecondPerBeat:Number;
        private var millisecondPerSecond:int = 1000;
        private var secondPerMinute:int = 60;
        private var schedule:Array;
        private var startMilliseconds:int;

        public function Dancer(diagram:MovieClip, bpm:int,
                frameRate:Number)
        {   
            this.startMilliseconds = getTimer();
            this.bpm = bpm;
            this.diagram = diagram;
            halfFrameMilliseconds = millisecondPerSecond 
                * (1.0 / frameRate) * 0.5;
            millisecondPerBeat = millisecondPerSecond 
                / (bpm / secondPerMinute);
            beatLength = diagram.totalFrames;
            schedule = populate(diagram, millisecondPerBeat);
            diagram.gotoAndStop(beatLength);
        }

        private function getBeat(milliseconds:int):int
        {
            return 1 + (
                (halfFrameMilliseconds + milliseconds) 
                    / millisecondPerBeat
                ) % beatLength;
        }

        /**
         * @return Fraction of beat off in range: [-0.5..0.5)
         *          Compensates for half frame lag.
         */
        private function getBeatOffset(milliseconds:int):Number
        {
            var beat:Number = (milliseconds - halfFrameMilliseconds)
                / millisecondPerBeat;
            var offset:Number = beat - Math.round(beat);
            return offset;
        }

        internal function isOnBeat(milliseconds:int):Boolean
        {
            var threshold:Number = // 0.125;
                                   0.2;
                                   // 0.25;
            var offset:Number = getBeatOffset(milliseconds);
            trace("Dancer.isOnBeat: " + offset.toFixed(2) 
                + " milliseconds " + milliseconds);
            var off:Number = Math.abs(offset);
            return off <= threshold;
        }

        /**
         * @param   diagram     Expects children named left and right on each frame.  Starts from last frame.
         * @return  Array of objects:  {x, y, millisecond}, one per frame, where a left or right foot had moved.  Plays through frames of diagram and returns to previous frame.
         */
        private function populate(diagram:MovieClip, millisecondPerBeat:int):Array
        {
            var currentFrame:int = diagram.currentFrame;
            var beatLength:int = diagram.totalFrames;
            diagram.gotoAndStop(beatLength);
            var previous:Object = {left: {x: diagram.left.x,
                                       y: diagram.left.y},
                                   right: {x: diagram.right.x,
                                       y: diagram.right.y}};
            var schedule:Array = [];
            for (var beat:int = 1; beat <= beatLength; beat++) {
                var step:Object = {millisecond: (beat - 1) * millisecondPerBeat };
                diagram.gotoAndStop(beat);
                move(previous, diagram, "left", step);
                move(previous, diagram, "right", step);
                schedule.push(step);
            }
            diagram.gotoAndStop(currentFrame);
            return schedule;
        }

        private function move(previous:Object, diagram:Object, childName:String, 
                              step:Object):void
        {
            if (diagram[childName].x != previous[childName].x 
             || diagram[childName].y != previous[childName].y) 
            {
                step[childName] = {};
                step[childName].x = diagram[childName].x;
                step[childName].y = diagram[childName].y;
                previous[childName].x = diagram[childName].x;
                previous[childName].y = diagram[childName].y;
            }
        }

        public function update(millisecond:int)
        {
            beat = getBeat(millisecond);
            if (diagram.currentFrame != beat) {
                var duration:int = getTimer() - this.startMilliseconds;
                diagram.gotoAndStop(beat);
                trace("Dancer.update: beat " + beat 
                    + " millisecond " + millisecond 
                    + " duration " + duration);
            }
        }
    }
}
