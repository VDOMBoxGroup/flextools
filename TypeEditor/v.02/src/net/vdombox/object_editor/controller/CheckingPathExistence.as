/*
class CheckingPathExistence checking the existence of path and sends a notification to execute commands LOAD_XML_FILES
*/
package net.vdombox.object_editor.controller
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class CheckingPathExistence extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void    
		{			
			var so:SharedObject = SharedObject.getLocal("directoryPath");
			if( so.data.path )
			{				
				facade.sendNotification( ApplicationFacade.LOAD_XML_FILES );
			}			
		}
	}
}

