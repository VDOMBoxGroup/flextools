package net.vdombox.object_editor.controller
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;
	
	import mx.utils.object_proxy;
	
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
	import org.osmf.utils.OSMFStrings;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class NewObjectTypePathCommand extends SimpleCommand 
	{
		override public function execute( note:INotification ) :void
		{
			var objTypeVO:ObjectTypeVO = note.getBody() as ObjectTypeVO;
						
			//get content of folder
			var so:SharedObject = SharedObject.getLocal("directoryPath");
			var path:String = so.data.path;
		
			//save as
			var docsDir:File = new File;
			docsDir.nativePath = path;
			try
			{
				docsDir.browseForSave("Save As");
				docsDir.addEventListener(Event.SELECT, saveData);
			}
			catch (error:Error)
			{
				trace("Failed:", error.message);
			}
			
			function saveData(event:Event):void 
			{					
				var newFile:File = event.target as File;
				objTypeVO.filePath = newFile.nativePath + ".xml";
				facade.sendNotification( ApplicationFacade.SAVE_OBJECT_TYPE, objTypeVO );				
			}						
		}
	}
}