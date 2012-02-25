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
	
	import mx.controls.Alert;
	
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
			
			try
			{
				fileContent = new XML(data);
			}
			catch ( e : * )
			{
			}
			
			dispatchEvent( new  TemplateLibEvent( TemplateLibEvent.RESULT_GETTED, fileContent,  "true"));
		}
		
		private  function dispathError():void
		{
			dispatchEvent( new  TemplateLibEvent( TemplateLibEvent.RESULT_GETTED, "false",  "false"));
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