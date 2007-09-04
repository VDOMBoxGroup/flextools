package vdom.connection.utils
{
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import mx.controls.Button;
	import flash.events.Event;
	import flash.events.DataEvent;
	import mx.controls.Alert;
	import mx.utils.Base64Decoder;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import vdom.connection.protect.Code;
//	import mx.containers.Panel;
	
   // Panel
	
	

    public dynamic class FileUpload extends EventDispatcher
    //extends UIComponent
    {
        // Hard-code the URL of the remote upload script.
        private const UPLOAD_URL:String = "http://192.168.0.101:80/echo.py?sid=";
        private var fr:FileReference;
 		private var code:Code = Code.getInstance();
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
         	fr.addEventListener(Event.CANCEL, cancelUpload );
            fr.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, completeHandler);
        }

        /**
         * Launch the browse dialog box which allows the user to select a file to upload to the server.
         */
        public function startUpload():void {
            fr.browse([imagesFilter]);
        }
        
        /**
         *  Cancel the upload.
         */
        private function cancelUpload(evt:Event):void {
           dispatchEvent(new UtilsEvent(UtilsEvent.FILE_UPLOAD_ERROR));
        }

        /**
         * Begin uploading the file specified in the UPLOAD_URL constant.
         */
        private function selectHandler(event:Event):void {
            
            request.url = UPLOAD_URL + code.sessionId;//
      		if(fr.size < 300000){
				fr.upload(request);
				btn.enabled = false;
			}else{
				Alert.show( "It's more then 300kb!\n Try again...");
				dispatchEvent(new UtilsEvent(UtilsEvent.FILE_UPLOAD_ERROR));
			}
        }
		
        /**
         * Once the upload has completed, decode geted data.
         */
        private function completeHandler(event:DataEvent):void {
        	fr.removeEventListener(Event.COMPLETE, completeHandler);

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
			utEvt.source = ld.content;
			dispatchEvent(utEvt);
		}		
	}
}