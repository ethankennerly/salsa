package com.finegamedesign.salsa
{
    import flash.display.MovieClip;
    import flash.geom.Point;
    import flash.utils.getTimer;

    internal final class Dancer
    {
        private var beat:int;
        private var beatLength:int;
        private var childNames:Array = ["left", "right"];
        private var diagram:MovieClip;
        private var halfFrameMilliseconds:Number;
        private var millisecondsPerBeat:Number;
        private var millisecondsPerSecond:int = 1000;
        private var secondPerMinute:int = 60;
        private var schedule:Array;
        private var startMilliseconds:int;

        public function Dancer(diagram:MovieClip, bpm:int,
                frameRate:Number)
        {   
            this.startMilliseconds = getTimer();
            this.diagram = diagram;
            halfFrameMilliseconds = millisecondsPerSecond 
                * (1.0 / frameRate) * 0.5;
            this.bpm = bpm;
            beatLength = diagram.totalFrames;
            diagram.gotoAndStop(beatLength);
        }

        internal function set bpm(value:int):void
        {
            millisecondsPerBeat = millisecondsPerSecond 
                / (value / secondPerMinute);
            schedule = populate(diagram, millisecondsPerBeat);
        }

        private function getBeat(milliseconds:int, offset:Number=0.0):int
        {
            return 1 + (
                (halfFrameMilliseconds + milliseconds
                    + offset * millisecondsPerBeat)
                    / millisecondsPerBeat
                ) % beatLength;
        }

        /**
         * @return Fraction of beat off in range: [-0.5..0.5)
         *          Compensates for half frame lag.
         */
        private function getBeatOffset(milliseconds:int):Number
        {
            var beat:Number = (milliseconds - halfFrameMilliseconds)
                / millisecondsPerBeat;
            var offset:Number = beat - Math.round(beat);
            return offset;
        }

        internal function getBeatText(milliseconds:int, isOnBeat:Boolean):String
        {
            var text:String = "";
            if (isOnBeat) {
                text = getBeat(milliseconds, 0.5).toString();
            }
            return text;
        }

        internal function isNear(milliseconds:int, global:Point):Boolean
        {
            var distanceMax:Number = 20.0;
                                     // 40.0;
                                     // 80.0;
            var local:Point = diagram.globalToLocal(global);
            var near:Boolean = false;
            var beatIndex:int = getBeat(milliseconds) - 1;
            var step:Object = schedule[beatIndex];
            var distance:Number = Number.POSITIVE_INFINITY;
            for each(var childName:String in childNames)
            {
                if (childName in step) {
                    var childDistance:Number = Point.distance(step[childName], local);
                    if (childDistance < distance) {
                        distance = childDistance;
                    }
                }
            }
            near = distance <= distanceMax;
            // trace("Dancer.isNear: " + near + " distance " + distance);
            return near;
        }

        internal function isOnBeat(milliseconds:int):Boolean
        {
            var threshold:Number = // 0.125;
                                   0.2;
                                   // 0.25;
            var offset:Number = getBeatOffset(milliseconds);
            // trace("Dancer.isOnBeat: " + offset.toFixed(2) + " milliseconds " + milliseconds);
            var off:Number = Math.abs(offset);
            return off <= threshold;
        }

        private function move(previous:Object, diagram:Object, childName:String, 
                              step:Object):void
        {
            if (diagram[childName].x != previous[childName].x 
             || diagram[childName].y != previous[childName].y) 
            {
                step[childName] = new Point(
                    diagram[childName].x,
                    diagram[childName].y);
                previous[childName].x = diagram[childName].x;
                previous[childName].y = diagram[childName].y;
            }
        }

        /**
         * @param   diagram     Expects children named left and right on each frame.  Starts from last frame.
         * @return  Array of objects:  {x, y, millisecond}, one per frame, where a left or right foot had moved.  Plays through frames of diagram and returns to previous frame.
         */
        private function populate(diagram:MovieClip, millisecondsPerBeat:int):Array
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
                var step:Object = {millisecond: (beat - 1) * millisecondsPerBeat };
                diagram.gotoAndStop(beat);
                for each(var childName:String in childNames) {
                    move(previous, diagram, childName, step);
                }
                schedule.push(step);
            }
            diagram.gotoAndStop(currentFrame);
            return schedule;
        }

        public function update(milliseconds:int):void
        {
            beat = getBeat(milliseconds);
            if (diagram.currentFrame != beat) {
                var duration:int = getTimer() - this.startMilliseconds;
                diagram.gotoAndStop(beat);
                updateText(beat);
                // trace("Dancer.update: beat " + beat + " milliseconds " + milliseconds + " duration " + duration);
            }
        }

        public function updateText(beat:int):void
        {
            var step:Object = schedule[beat - 1];
            for each(var childName:String in childNames) {
                var text:String = "";
                if (childName in step) {
                    text = beat.toString();
                }
                diagram[childName].txt.text = text;
            }
        }
    }
}
