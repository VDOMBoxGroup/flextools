package
{
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import spinnerFolder.SpinnerPopUpManager;
	import spinnerFolder.SpinnerPopupMessages;
	
	public class ProductXMLLoader extends EventDispatcher
	{
		public static var USER_CANCELED				: String = "USER_CANCELED";
		public static var XML_FILE_LOADED			: String = "XML_FILE_LOADED";
		public static var XML_FILE_LOADING_ERROR	: String = "XML_FILE_LOADING_ERROR";
		public static var XML_FILE_LOADING_STARTED	: String = "XML_FILE_LOADING_STARTED";
		
		private var file					: File;
		
		private var spinnerAdded			: Boolean;
		
		private var spinnerManager			: SpinnerPopUpManager = SpinnerPopUpManager.getInstance();
		private var xmlLoaded				:Boolean;
		
		public function ProductXMLLoader()
		{
		}
		
		public function selectAndLoadXMLFile():void
		{
			var textTypeFilter:FileFilter = new FileFilter("XML Files (*.xml)",	"*.xml");
			
			file = new File();
			
			file.addEventListener(Event.SELECT, onXMLFileSelected); 
			file.addEventListener(Event.CANCEL, onCancelSelectXML); 
			file.addEventListener(IOErrorEvent.IO_ERROR, onError); 
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError); 
			
			file.browse([textTypeFilter]);
		}
		
		public function loadXMLFile(path : String):void
		{
			file = new File(path);
			
			if (!file.hasEventListener(IOErrorEvent.IO_ERROR))
				file.addEventListener(IOErrorEvent.IO_ERROR,	onError);
			
			if (!file.hasEventListener(SecurityErrorEvent.SECURITY_ERROR))
				file.addEventListener(SecurityErrorEvent.SECURITY_ERROR,	onError);
			
			xmlLoaded = false;
			
			file.addEventListener(Event.COMPLETE,	onXMLFileLoadComplete);
			
			file.load();
		}
		
		private function onXMLFileSelected(aEvent:Event):void
		{
			this.dispatchEvent(new Event(XML_FILE_LOADING_STARTED));
			
			xmlLoaded = false;
			
			file.addEventListener(Event.COMPLETE, onXMLFileLoadComplete);		
			
			file.load();
			
			setTimeout(timerHandler, 1000);
		}
		
		private function timerHandler():void 
		{
			if (xmlLoaded)
				return;
			
			spinnerAdded = true;
			
			spinnerManager.addEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_ADDED, onSpinnerAdded);
			spinnerManager.showSpinner();
		}
		
		private function onSpinnerAdded (evt:Event):void
		{
			spinnerManager.removeEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_ADDED, onSpinnerAdded);
			
			spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCT_XML_LOADING);
		}
		
		private function onXMLFileLoadComplete(aEvent:Event):void
		{
			xmlLoaded = true;
			
			file.removeEventListener(Event.SELECT, 						onXMLFileSelected); 
			file.removeEventListener(Event.CANCEL,						onCancelSelectXML); 
			file.removeEventListener(IOErrorEvent.IO_ERROR, 			onError); 
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			file.removeEventListener(Event.COMPLETE, 					onXMLFileLoadComplete);
			
			if (spinnerAdded)
			{
				spinnerAdded = false;
				
				spinnerManager.addEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, spinnerHideHandler);
				spinnerManager.hideSpinner();
				
				return;
			} 
			
			this.dispatchEvent(new Event(XML_FILE_LOADED));
		}
		
		private function spinnerHideHandler(evt:Event):void
		{
			spinnerManager.removeEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, spinnerHideHandler);
			
			this.dispatchEvent(new Event(XML_FILE_LOADED));
		}
		
		private function onCancelSelectXML(aEvent:Event):void
		{
			file.removeEventListener(Event.SELECT, 						onXMLFileSelected); 
			file.removeEventListener(Event.CANCEL,						onCancelSelectXML); 
			file.removeEventListener(IOErrorEvent.IO_ERROR, 			onError); 
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			
			this.dispatchEvent(new Event(USER_CANCELED));
		}
		
		private function onError(aEvent:Event):void
		{
			file.removeEventListener(Event.SELECT, 						onXMLFileSelected); 
			file.removeEventListener(Event.CANCEL,						onCancelSelectXML); 
			file.removeEventListener(IOErrorEvent.IO_ERROR, 			onError); 
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			file.removeEventListener(Event.COMPLETE, 					onXMLFileLoadComplete);
			
			this.dispatchEvent(new Event(XML_FILE_LOADING_ERROR));
		} 
		
		public function get xmlFile():File
		{
			return this.file;
		}
		
	}
}