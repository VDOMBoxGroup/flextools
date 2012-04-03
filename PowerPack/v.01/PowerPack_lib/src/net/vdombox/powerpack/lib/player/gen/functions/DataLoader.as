package net.vdombox.powerpack.lib.player.gen.functions
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.utils.Base64Decoder;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;
	import net.vdombox.powerpack.lib.player.events.TemplateLibEvent;

	[Event(name="rusulGetted", type="net.vdombox.powerpack.lib.player.events.TemplateLibEvent")]

	public class DataLoader extends EventDispatcher
	{
		public function DataLoader() 
		{
		}
		
		private	var loader:URLLoader = new URLLoader ();
		
		private var path : String;
		private var firstTry : Boolean = true;
		
		public function load( path : String ):void
		{
			this.path = path;
			
			if ( firstTry )
				addHandlers();
			
			var request:URLRequest = new URLRequest ( path );
			
			loader.load ( request );
		}
		
		private function addHandlers():void
		{
			loader.addEventListener ( Event.COMPLETE, completeHadler, false, 0, true );
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false, 0, true);
		} 
		
		private function removeHandlers():void
		{
			loader.removeEventListener ( Event.COMPLETE, completeHadler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
		}
		
		private function completeHadler( evt:Event ):void
		{
			removeHandlers();
			
			dispathcSuccess( evt.target.data );
		}
		
		private function dispathcSuccess( data : Object ):void
		{
			var fileContent : Object = data;
			
			if (loadedXMLFormat)
			{
				fileContent = getXMLData(data);
			}
			
			dispatchEvent( new  TemplateLibEvent( TemplateLibEvent.COMPLETE, fileContent,  "true"));
		}
		
		private function get loadedXMLFormat () : Boolean
		{
			return FileUtils.getFileExtention(path).toLowerCase() == "xml";
		}
		
		private function getXMLData (data : Object) : Object
		{
			try
			{
				var xmlData : XML = XML(data);
				
				if (!xmlData.name() || xmlData.name().localName != "Application")
					xmlData = decodeXMLData(xmlData);
			}
			catch ( e : Error )
			{
				return data;
			}
			
			return xmlData;
		}
		
		private function decodeXMLData (sourceData : XML) : XML
		{
			var decoder : Base64Decoder = new Base64Decoder();
			decoder.decode( sourceData.toString() );
			
			var decodedByteArray : ByteArray = decoder.toByteArray();
			decodedByteArray.position = 0;
			decodedByteArray.uncompress();
			
			decodedByteArray.position = 0;
			var decodedData : String = decodedByteArray.readUTFBytes(decodedByteArray.bytesAvailable);
			
			if (!decodedData) return sourceData;
			
			return new XML(decodedData);
		}
		
		private  function dispathError():void
		{
			dispatchEvent( new  TemplateLibEvent( TemplateLibEvent.COMPLETE, "false",  "false"));
		}
		
		private function errorHandler( event : IOErrorEvent): void
		{
			if ( isXMLFileRequested && firstTry )
			{
				shortPathOpen();
			}
			else
			{
				removeHandlers();
				
				dispathError();
			}
		}
		
		private function get isXMLFileRequested():Boolean
		{
			var count : int = 4;
			var fileType : String = path.substring( path.length - count).toLowerCase();
			
			return fileType == ".xml"
		}
		
		private  function shortPathOpen():void
		{
			firstTry = false;
			
			var index :int = path.lastIndexOf( "/");
			
			path = path.substring( index );
			
			load ( path );
		}
	}
}