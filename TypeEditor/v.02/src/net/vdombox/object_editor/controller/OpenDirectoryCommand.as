package net.vdombox.object_editor.controller
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;

	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.view.ObjectsAccordion;
	import net.vdombox.object_editor.view.mediators.AccordionMediator;

	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.facade.*;
	import org.puremvc.as3.patterns.facade.Facade;

	import spark.components.NavigatorContent;	

	public class OpenDirectoryCommand extends SimpleCommand
	{
		override public function execute( note:INotification ) :void    
		{	


			var directory:File = File.applicationStorageDirectory;				
			try
			{
				directory.browseForDirectory("Select Directory");
				directory.addEventListener(Event.SELECT, directorySelected);
//TODO: write path into file. какой файл?    directory.Path;
			}
			catch (error:Error)
			{
				trace("Failed:", error.message);
			}

			function directorySelected(event:Event):void 
			{
				directory = event.target as File;			
				//get content of folder
				var filesArray:Array = directory.getDirectoryListing();
				var accMediator:AccordionMediator = facade.retrieveMediator(AccordionMediator.NAME) as AccordionMediator;			
				accMediator.removeAllObjects();

				for(var i:uint = 0; i < filesArray.length; i++)
				{	
					var file:File = filesArray[i] as File;
					if (!file.isDirectory)
					{						
						if(i != 0)
						{							
							var stream:FileStream = new FileStream();   
							stream.open(filesArray[i], FileMode.READ);
							var data:String = stream.readUTFBytes(stream.bytesAvailable);
							var myXML:XML = new XML(data);	

							var item:Item = new Item;
							item.groupName = myXML.Information.Category.toString();
							item.label = myXML.Information.Name.toString();

							item.path  = file.nativePath;// or .url
//							item.img = "view\pictures\picture.jpg";						
//							facade.sendNotification(ApplicationFacade.NEW_NAVIGATOR_CONTENT, item);

							accMediator.newContent(item);									
							stream.close();												
						}	
					}
				}	
			}
		}
	}	
}

