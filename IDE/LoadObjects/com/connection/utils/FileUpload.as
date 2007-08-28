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
	import flash.display.DisplayObject;
	import com.connection.soap.Soap;
	import mx.utils.Base64Decoder;
	import flash.display.Loader;
	
	

    public dynamic class FileUpload extends EventDispatcher
    //extends UIComponent
    {
        // Hard-code the URL of the remote upload script.
        private const UPLOAD_URL:String = "http://192.168.0.23:82/echo.py?sid=";
        private var fr:FileReference;
 		private var code:Code = Code.getInstance();
 		private var ws:WebService;
 		private var exteract:Extract = new Extract();
 		public var displObj:DisplayObject;// = new DisplayObject;
 		private var times:uint;
 		private var time:uint;
 		private var myTimer:Timer = new Timer(100, 1);
 		private var btn:Button;
 		private var imagesFilter:FileFilter = new FileFilter("Images: *.jpg *.gif; *.png", "*.jpg;*.gif;*.png");
 		private var request:URLRequest = new URLRequest(); 
 		private var ld:Loader = new Loader();
 		private var bs:Base64Decoder = new Base64Decoder();
 		private var utEvt:UtilsEvent = new UtilsEvent(UtilsEvent.FILE_UPLOAD_COMPLETE)

        public function FileUpload(btn:Button):void
        {
        	this.btn = btn;
        	fr = new FileReference();
            fr.addEventListener(Event.SELECT, selectHandler);
        //    fr.addEventListener(Event.OPEN, openHandler);
         //   fr.addEventListener(ProgressEvent.PROGRESS, progressHandler);
         	fr.addEventListener(Event.CANCEL, cancelUpload );
            fr.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, completeHandler);
        }

        /**
         * Launch the browse dialog box which allows the user to select a file to upload to the server.
         */
        public function startUpload():void {
   //     	this.ws = ws;
            fr.browse([imagesFilter]);
        }
        
        /**
         * Immediately cancel the upload in progress and disable the cancel button.
         */
        public function cancelUpload(evt:Event):void {
           dispatchEvent(new UtilsEvent(UtilsEvent.FILE_UPLOAD_ERROR));
        }

        /**
         * Begin uploading the file specified in the UPLOAD_URL constant.
         */
        private function selectHandler(event:Event):void {
            
            request.url = UPLOAD_URL + code.sessionId;// Soap.getSid();
            time = getTimer();
            times = getTimer();
        //    trace('File size: '+ Math.round(fr.size/1000)+ "KB" );
			if(fr.size < 300000){
				fr.upload(request);
				btn.enabled = false;
			}else{
				Alert.show( "It's more then 300kb!\n Try again...");
				dispatchEvent(new UtilsEvent(UtilsEvent.FILE_UPLOAD_ERROR));
			}
        }
		
        /**
         * Once the upload has completed, change the progress bar's label and 
         * disable the "Cancel" button since the upload is already completed.
         */
        private function completeHandler(event:DataEvent):void {
        //	trace('result:' + event.text);
        	fr.removeEventListener(Event.COMPLETE, completeHandler);
        	
        	var bs:Base64Decoder = new Base64Decoder();
        	bs.decode(event.text);
 			ld.loadBytes(bs.drain());
 			utEvt.base64data = event.text;
			ld.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
        }

		
		/**
		 *  ------ Extract Data
		 */
		private function loadComplete(evt:Event):void
		{
			btn.enabled = true;
		//	var utEvt:UtilsEvent = new UtilsEvent(UtilsEvent.FILE_UPLOAD_COMPLETE,ld.content, 'str')
			utEvt.source = ld.content;
			dispatchEvent(utEvt);
		}		
	/*	private function dispatches(evt:UtilsEvent):void{
			btn.enabled = true;
			var utEvt:UtilsEvent = new UtilsEvent(UtilsEvent.FILE_UPLOAD_COMPLETE, evt.source)
			dispatchEvent(utEvt);
		}*/
    }
}