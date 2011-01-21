package net.vdombox.object_editor.controller
{
	import flash.filesystem.File;
	
	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.model.proxy.ObjectsProxy;
	import net.vdombox.object_editor.view.mediators.ObjectsAccordionMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class FillAccordionCommand extends SimpleCommand 
	{
		override public function execute( note:INotification ) :void
		{
			//get content of folder
			var directory:File =  new File;
			directory.nativePath = note.getBody() as String;
			var filesArray:Array = directory.getDirectoryListing();
			var accMediator:ObjectsAccordionMediator = facade.retrieveMediator(ObjectsAccordionMediator.NAME) as ObjectsAccordionMediator;			
			var itemProxy:ObjectsProxy = facade.retrieveProxy(ObjectsProxy.NAME) as ObjectsProxy;
			
			accMediator.removeAllObjects();
			
			for(var i:uint = 0; i < filesArray.length; i++)
			{	
				var file:File = filesArray[i] as File;
				if ( !file.isDirectory )
				{				
					var item:Item = itemProxy.getItem(file) ;					
					facade.sendNotification(ApplicationFacade.NEW_NAVIGATOR_CONTENT, item);												
				}
			}	
		}
	}
}