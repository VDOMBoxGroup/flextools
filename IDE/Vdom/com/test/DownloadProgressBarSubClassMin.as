package com.test
{
    import flash.display.*;
    import flash.text.*;
    import flash.utils.*;
    import flash.events.*;
    import mx.preloaders.*;
    import mx.events.*;
    import flash.net.URLRequest;
    import flash.net.URLLoader;


    public class DownloadProgressBarSubClassMin extends DownloadProgressBar
    {
		private var progressText:TextField;
    	
        public function DownloadProgressBarSubClassMin()
        {   
        	super();

             // Configure the TextField for progress messages.
            progressText = new TextField(); 
            progressText.x = 10;    
            progressText.y = 90;
            progressText.width = 400;
            progressText.height = 400;
        
            addChild(progressText);

        }
        
        // Override to return true so progress bar appears
        // during initialization.       
        override protected function showDisplayForInit(elapsedTime:int, 
            count:int):Boolean {
                return true;
        }

        // Override to return true so progress bar appears during download.     
        override protected function showDisplayForDownloading(
            elapsedTime:int, event:ProgressEvent):Boolean {
                return true;
        }
        
        override public function set preloader(value:Sprite):void {

            // Listen for the relevant events
            value.addEventListener(
            	FlexEvent.INIT_PROGRESS, initProgressHandler);
            value.addEventListener(
                FlexEvent.INIT_COMPLETE, myHandleInitEnd);
        }
        
        private function myHandleInitEnd(event:Event):void {
    	
            var XML_URL:String = 'settings.xml';
			var myXMLURL:URLRequest = new URLRequest(XML_URL);
			var myLoader:URLLoader = new URLLoader(myXMLURL);
			progressText.appendText('settings.xml load complete');
			myLoader.addEventListener("complete", settingsLoaded);
           
        }
        
        private function settingsLoaded(event:Event):void {
        	var timer:Timer = new Timer(5000,1);
            timer.addEventListener(TimerEvent.TIMER, dispatchComplete);
            timer.start();
            
        }
        
        private function dispatchComplete(event:TimerEvent):void {
            dispatchEvent(new Event(Event.COMPLETE));
        }



    }

}




