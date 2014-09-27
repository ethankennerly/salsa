package com.finegamedesign.salsa
{
    import org.si.sion.SiONDriver;
    import org.si.sion.midi.SMFData;

    public class Midi
    {
        [Embed(source="../../../../sfx/Latin_Rhythms_Salsa.mid", 
            mimeType="application/octet-stream")]
        private var SalsaClass:Class;
        internal var salsa:* = new SalsaClass();

        public function Midi()
        {
        }

        // http://stackoverflow.com/questions/2035948/play-midi-files-in-flash
        internal function play(bytes:*, bpm:int=-1):*
        {
            var smfData:SMFData = new SMFData();
            var driver:SiONDriver = new SiONDriver();
            smfData.loadBytes(bytes);
            driver.play(smfData);
            if (1 <= bpm) {
                driver.bpm = bpm;
            }
            return driver;
        }
    }
}
