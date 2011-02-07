package net.vdombox.object_editor.controller
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;

	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.model.proxy.ObjectsProxy;

	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	import spark.components.NavigatorContent;

	public class OpenDirectoryCommand extends SimpleCommand
	{
		override public function execute( note:INotification ) :void    
		{	
			var so:SharedObject	 = SharedObject.getLocal("directoryPath");
			var directory:File   = new File;			
			directory.nativePath = so.data.path;		

			try
			{
				directory.browseForDirectory("Select Directory");
				directory.addEventListener(Event.SELECT, directorySelected);
			}
			catch (error:Error)
			{
				trace("Failed:", error.message);
			}			

			function directorySelected(event:Event):void 
			{
				directory = event.target as File;
				so.clear();
				so.data.path = directory.nativePath;				
				so.flush();				
				facade.sendNotification( ApplicationFacade.PARSE_XML_FILES, directory.nativePath );
			}			
		}
	}	
}

