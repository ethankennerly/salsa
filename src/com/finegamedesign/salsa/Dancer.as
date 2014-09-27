package com.finegamedesign.salsa
{
    import flash.display.MovieClip;

    internal final class Dancer
    {
        private var beat:int;
        private var beatLength:int;
        private var bpm:int;
        private var diagram:MovieClip;
        private var millisecondPerBeat:Number;
        private var millisecondPerSecond:int = 1000;
        private var secondPerMinute:int = 60;

        public function Dancer(diagram:MovieClip, bpm:int)
        {
            this.bpm = bpm;
            this.diagram = diagram;
            millisecondPerBeat = millisecondPerSecond 
                / (bpm / secondPerMinute);
            beatLength = diagram.totalFrames;
            diagram.gotoAndStop(beatLength);
        }

        private function getBeat(milliseconds:int):int
        {
            return 1 + (milliseconds / millisecondPerBeat) % beatLength;
        }

        public function update(milliseconds:int)
        {
            beat = getBeat(milliseconds);
            if (diagram.currentFrame != beat) {
                diagram.gotoAndStop(beat);
                trace("Dancer.update: beat " + beat + " milliseconds " + milliseconds );
            }
        }
    }
}
