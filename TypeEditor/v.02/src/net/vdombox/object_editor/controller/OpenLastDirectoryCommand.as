/*
   Class OpenLastDirectoryCommand if path to types exist, loaded types
 */
package net.vdombox.object_editor.controller
{
	import flash.filesystem.File;
	import flash.net.SharedObject;

	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class OpenLastDirectoryCommand extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void    
		{			
			var so:SharedObject = SharedObject.getLocal("directoryPath");
			var path:String = so.data.path;
			if (path)
				facade.sendNotification( ApplicationFacade.PARSE_XML_FILES, path );
			else
				so.data.path = File.documentsDirectory.nativePath;
		}
	}
}

