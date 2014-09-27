package com.finegamedesign.salsa
{
    import org.si.sion.SiONDriver;
    import org.si.sion.midi.SMFData;

    public class Midi
    {
        [Embed(source="../../../../sfx/Latin_Rhythms_Salsa.mid", 
            mimeType="application/octet-stream")]
        private static var SalsaClass:Class;
        internal var salsaBytes:* = new SalsaClass();

        internal var driver:SiONDriver = new SiONDriver();
        /**
         * MuseScore shows BPM at 92.
         * smfData shows BPM at 91.
         */
        internal var smfData:SMFData = new SMFData();

        public function Midi()
        {
        }

        // http://stackoverflow.com/questions/2035948/play-midi-files-in-flash
        internal function play(bytes:*):SiONDriver
        {
            smfData.loadBytes(bytes);
            driver.play(smfData);
            if (1 <= bpm) {
                driver.bpm = bpm;
            }
            return driver;
        }
    }
}
