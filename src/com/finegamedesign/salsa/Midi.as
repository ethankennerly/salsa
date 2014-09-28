package com.finegamedesign.salsa
{
    import flash.events.Event;

    import org.si.sion.SiONDriver;
    import org.si.sion.midi.SMFData;

    public class Midi
    {
        [Embed(source="../../../../sfx/Latin_Rhythms_Salsa.mid", 
            mimeType="application/octet-stream")]
        private static var SalsaClass:Class;
        internal var salsaBytes:* = new SalsaClass();
        private var overrideBpm:int;

        internal var driver:SiONDriver = new SiONDriver();
        /**
         * MuseScore shows BPM at 92.
         * smfData shows BPM at 91.
         */
        internal var smfData:SMFData = new SMFData();

        public function Midi()
        {
        }

        internal function get bpm():int
        {
            return driver.bpm;
        }

        internal function set bpm(value:int):void
        {
            overrideBpm = value;
        }

        // http://stackoverflow.com/questions/2035948/play-midi-files-in-flash
        internal function play(bytes:*):SiONDriver
        {
            smfData.loadBytes(bytes);
            driver.play(smfData);
            trace("Midi.play: smfData " + smfData.toString());
            return driver;
        }

        internal function togglePlay(event:Event):void
        {
            if (driver.isPaused) {
                driver.resume();
            }
            else {
                driver.pause();
            }
            event.stopPropagation();
        }

        internal function update():void
        {
            if (1 <= overrideBpm && overrideBpm != driver.bpm) {
                driver.bpm = overrideBpm;
            }
        }
    }
}
