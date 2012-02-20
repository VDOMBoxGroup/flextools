package net.vdombox.powerpack.lib.player.gen.functions
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	
	import net.vdombox.powerpack.lib.player.events.TemplateLibEvent;

	[Event(name="rusulGetted", type="net.vdombox.powerpack.lib.player.events.TemplateLibEvent")]

	public class File extends EventDispatcher
	{
		public function File() 
		{
		}
		
		public function loadDataFrom( path : String ):void
		{
			var loader:URLLoader = new URLLoader ();
			var request:URLRequest = new URLRequest ( path );
		
			// Add Handlers
			loader.addEventListener ( Event.COMPLETE, completeHadler, false, 0, true );
			loader.addEventListener(IOErrorEvent.IO_ERROR, fullPathOpenErrorHandler, false, 0, true);
			
			loader.load ( request );
			
			function completeHadler( evt:Event ):void
			{
				removeHandlers();
				dispathcSuccess( evt.target.data );
			}
			
			function fullPathOpenErrorHandler( event : IOErrorEvent): void
			{
				var count : int = 4;
				var fileExtension : String = path.substring( path.length - count).toLowerCase();
				if ( fileExtension == ".xml")
				{
					shortPathOpen();
				}
				else
				{
					removeHandlers();
					dispathError();
				}
			}
			
			 function shortPathOpen():void
			{
				 loader.removeEventListener(IOErrorEvent.IO_ERROR, fullPathOpenErrorHandler);
				 loader.addEventListener(IOErrorEvent.IO_ERROR, shortPathOpenErrorHandler, false, 0, true);
				 
				 var index :int = path.lastIndexOf( "/");
				 
				 path = path.substring( index );
				 request = new URLRequest ( path );
				 
				 loader.load ( request );
			}
			
			
			function shortPathOpenErrorHandler( event : IOErrorEvent): void
			{
				removeHandlers();
				dispathError();
			}
			
			
			function removeHandlers():void
			{
				loader.removeEventListener ( Event.COMPLETE, completeHadler);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, fullPathOpenErrorHandler);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, shortPathOpenErrorHandler);
			}
		}
		
		private function dispathcSuccess( data : Object ):void
		{
			try
			{
				var xml : XML = new XML(data);
				dispatchEvent( new  TemplateLibEvent( TemplateLibEvent.RESULT_GETTED, xml,  "true"));
			}
			catch ( e : * )
			{
				dispatchEvent( new  TemplateLibEvent( TemplateLibEvent.RESULT_GETTED, data,  "true"));
			}
		}
		
		private  function dispathError():void
		{
			dispatchEvent( new  TemplateLibEvent( TemplateLibEvent.RESULT_GETTED, "false",  "false"));
		}
		
	}
}