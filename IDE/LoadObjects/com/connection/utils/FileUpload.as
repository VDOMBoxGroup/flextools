package com.connection.utils
{
    import flash.events.*;
    import flash.net.FileReference;
    import flash.net.URLRequest;
    
    import mx.controls.Button;
    import mx.controls.ProgressBar;
    import mx.core.UIComponent;
 //   import com.vdom.connect.Soap;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import com.connection.protect.Code;
    import com.connection.soap.SGetEcho;
    import com.connection.soap.SoapEvent;
    import mx.rpc.soap.WebService;
    import mx.controls.Image;
    import com.connection.utils.Extract;
	import com.connection.soap.SoapEvent;
	import flash.utils.getTimer;
	import mx.controls.Alert;
	import flash.net.FileFilter;
	
	

    public dynamic class FileUpload extends SoapEvent
    //extends UIComponent
    {
        // Hard-code the URL of the remote upload script.
        private const UPLOAD_URL:String = "http://192.168.0.23:82/echo.py?sid=";
        private var fr:FileReference;
 		private var code:Code = Code.getInstance();
 		private var ws:WebService;
 		private var exteract:Extract = new Extract();
 		public var img:Image = new Image();
 		private var times:uint;
 		private var time:uint;
 		private var myTimer:Timer = new Timer(100, 1);
 		private var btn:Button;
 		 

        public function FileUpload() {
        	
        	fr = new FileReference();
            fr.addEventListener(Event.SELECT, selectHandler);
        //    fr.addEventListener(Event.OPEN, openHandler);
         //   fr.addEventListener(ProgressEvent.PROGRESS, progressHandler);
         	fr.addEventListener(Event.CANCEL, cancelUpload );
            fr.addEventListener(Event.COMPLETE, completeHandler);
        }

        /**
         * Launch the browse dialog box which allows the user to select a file to upload to the server.
         */
        public function startUpload(ws:WebService,btn:Button):void {
        	this.ws = ws;
        	this.btn = btn;
        	var imagesFilter:FileFilter = new FileFilter("Images: *.jpg *.gif; *.png", "*.jpg;*.gif;*.png");
            fr.browse([imagesFilter]);
        }
        
        /**
         * Immediately cancel the upload in progress and disable the cancel button.
         */
        public function cancelUpload(evt:Event):void {
            //fr.cancel();
           dispatchEvent(new Event(SoapEvent.GET_ECHO_ERROR));
        }

                /**
         * Begin uploading the file specified in the UPLOAD_URL constant.
         */
        private function selectHandler(event:Event):void {
            var request:URLRequest = new URLRequest();
            request.url = UPLOAD_URL + code.sessionId;// Soap.getSid();
            time = getTimer();
            times = getTimer();
            trace('File size: '+ Math.round(fr.size/1000)+ "KB" );
			if(fr.size < 300000){
				fr.upload(request);
				btn.enabled = false;
			}else{
				Alert.show( "It's more then 300kb!\n Try again...");
				dispatchEvent(new Event(SoapEvent.GET_ECHO_ERROR));
			}
        }
		
        /**
         * Once the upload has completed, change the progress bar's label and 
         * disable the "Cancel" button since the upload is already completed.
         */
        private function completeHandler(event:Event):void {
        	fr.removeEventListener(Event.COMPLETE, completeHandler);
			var myTimer:Timer = new Timer(100, 1);
            myTimer.addEventListener("timer", runWebService);
            myTimer.start(); 
            
            trace('1. Time to upload: '+ (getTimer() - time)  + 'c.');  
            time = getTimer();      
        }

		private var ge:SGetEcho = new SGetEcho();
		private function runWebService(ev:Event):void{
			myTimer.removeEventListener("timer", runWebService);
			ge.execute(ws);
		
			ge.addEventListener(SoapEvent.GET_ECHO_OK, extractData);
			ge.addEventListener(SoapEvent.GET_ECHO_ERROR, dispatchEvent);
			trace('2. Time to Run WebServise: '+ (getTimer() - time)  + 'c.');
			time = getTimer();
		}
		
		private var extract:Extract = new Extract();
		private function extractData(evt:Event):void{
			trace('3.Time to get result from SOAP servise: '+ (getTimer() - time) + 'c.');
			time = getTimer();
			extract.unziping(ge.getResult()); 
			extract.addEventListener(SoapEvent.UNZIP_OK, getImage);
			ge.removeEventListener(SoapEvent.GET_ECHO_OK, extractData);
		}		
		
		private function getImage(evt:Event):void{
			btn.enabled = true;
			//necessary data for as
			img = extract.getImage();
		//	trace ("img File Up3: "+ img.width);
			trace('5.Time to UnZip: '+ (getTimer() - time) + 'c.');
			time = getTimer();
			dispatchEvent(new Event(SoapEvent.GET_ECHO_OK));
			
		}
		
		private function dispatches(evt:Event):void{
			btn.enabled = true;
			dispatchEvent(evt);
		}
	
        public function getResul():Image{
        	//return ge.getResult();
        	trace('6. REzult Time: '+ (getTimer() - times) + 'c.');
        	return  img;
        }
    }
}