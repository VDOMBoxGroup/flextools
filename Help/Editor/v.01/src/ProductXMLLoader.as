package
{
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class ProductXMLLoader extends EventDispatcher
	{
		public static var USER_CANCELED		: String = "USER_CANCELED";
		public static var XML_FILE_LOADED	: String = "XML_FILE_LOADED";
		
		private var file					: File;
		
		public function ProductXMLLoader()
		{
		}
		
		public function selectAndLoadXMLFile():void
		{
			file = new File();
			
			file.addEventListener(Event.SELECT, onXMLFileSelected); 
			file.addEventListener(Event.CANCEL, onCancelSelectXML); 
			file.addEventListener(IOErrorEvent.IO_ERROR, onError); 
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError); 
			var textTypeFilter:FileFilter = new FileFilter("XML Files (*.xml)",	"*.xml"); 
			file.browse([textTypeFilter]);
		}
		
		private function onXMLFileSelected(aEvent:Event):void
		{
			trace("[ProductXMLLoader] onXMLFileSelected");
			file.addEventListener(Event.COMPLETE, onXMLFileLoadComplete); 
			file.load();
		}
		
		private function onXMLFileLoadComplete(aEvent:Event):void
		{
			trace ("[ProductXMLLoader] onXMLFileLoadComplete");
			file.removeEventListener(Event.SELECT, 						onXMLFileSelected); 
			file.removeEventListener(Event.CANCEL,						onCancelSelectXML); 
			file.removeEventListener(IOErrorEvent.IO_ERROR, 			onError); 
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			file.removeEventListener(Event.COMPLETE, 					onXMLFileLoadComplete);
			
			this.dispatchEvent(new Event(XML_FILE_LOADED));
		}
		
		private function onCancelSelectXML(aEvent:Event):void
		{
			trace ("[ProductXMLLoader] onCancelSelectXML");
			this.dispatchEvent(new Event(USER_CANCELED));
		}
		
		private function onError(aEvent:Event):void
		{
			trace ("[ProductXMLLoader] onError");
		} 
		
		public function get xmlFile():File
		{
			return this.file;
		}
		
	}
}