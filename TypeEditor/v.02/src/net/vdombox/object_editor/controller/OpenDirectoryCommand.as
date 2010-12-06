package net.vdombox.object_editor.controller
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;
	
	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.view.mediators.AccordionMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.NavigatorContent;

	public class OpenDirectoryCommand extends SimpleCommand
	{
		override public function execute( note:INotification ) :void    
		{	
			var so:SharedObject = SharedObject.getLocal("directoryPath");
			var directory:File = File.applicationStorageDirectory;
			
			if( so.data.path )
			{					
				directory.nativePath = so.data.path;
				parseXMLFiles();
			}
			else
			{							
				try
				{
					directory.browseForDirectory("Select Directory");
					directory.addEventListener(Event.SELECT, directorySelected);
				}
				catch (error:Error)
				{
					trace("Failed:", error.message);
				}
			}
			
			function directorySelected(event:Event):void 
			{
				directory = event.target as File;
				so.clear();
				so.data.path = directory.nativePath;				
				so.flush();				
				parseXMLFiles();
			}

			function parseXMLFiles():void
			{
				//get content of folder
				var filesArray:Array = directory.getDirectoryListing();
				var accMediator:AccordionMediator = facade.retrieveMediator(AccordionMediator.NAME) as AccordionMediator;			
				accMediator.removeAllObjects();

				for(var i:uint = 0; i < filesArray.length; i++)
				{	
					var file:File = filesArray[i] as File;
					if ( !file.isDirectory )
					{
						var stream:FileStream = new FileStream();   
						stream.open(filesArray[i], FileMode.READ);
						var data:String = stream.readUTFBytes(stream.bytesAvailable);
						var objectXML:XML = new XML(data);	

						var item:Item = new Item;
						var information:XML = objectXML.Information[0];

						item.groupName = information.Category.toString();
						item.label = information.Name.toString();

						var imgResourseID:String =  getImgResourseID(information);
						item.img = getImgResourse(objectXML, imgResourseID)	;
						item.path  = file.nativePath;// or .url

						accMediator.newContent(item);									
						stream.close();												
					}
				}	
			}

			function getImgResourseID(information:XML):String
			{
				var iconValue:String  = information.Icon.toString();
				var phraseRE:RegExp = /^(?:#Res\(([-a-zA-Z0-9]*)\))|(?:([-a-zA-Z0-9]*))/;

				var imgResourseID:String = "";
				var matchResult : Array = iconValue.match( phraseRE );
				if (matchResult)
				{
					imgResourseID = matchResult[1]
//					trace("imgResourseID: "+imgResourseID);
				}
				return imgResourseID;
			}

			function getImgResourse(objectXML:XML, imgResourseID:String):String
			{
				var imgResourse:String = "";
				var resource: XML = objectXML.Resources.Resource.(@ID == imgResourseID)[0];	
				if (resource) 
				{
					imgResourse =  resource.toString();
				}
				else
				{
					trace("resource: " +imgResourseID+" not found!");
				}

				return imgResourse;
			}
		}
	}	
}

