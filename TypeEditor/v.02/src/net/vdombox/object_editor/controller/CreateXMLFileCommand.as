package net.vdombox.object_editor.controller
{
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.object_editor.view.mediators.CreateObjectMediator;
	import net.vdombox.object_editor.view.popups.NameObject;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class CreateXMLFileCommand extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void  
		{
			//open example file in applicationDirectory
			var original:File = File.applicationDirectory;			
			original = original.resolvePath("assets/newObject/newObject.xml");			
			trace(original.exists);
			
			//create new file for new Object
			var newFile:File = File.documentsDirectory;
			var newFilePath:String = "";
			
			var so:SharedObject = SharedObject.getLocal("directoryPath");
			var path:String = so.data.path;
			if (path)
				newFilePath = path;
			else
				newFilePath = File.documentsDirectory.nativePath;															
			
			var viewDispl:ObjectEditor2 = note.getBody() as ObjectEditor2;
			var popup:NameObject = NameObject(PopUpManager.createPopUp(viewDispl, NameObject, true));
			popup.addEventListener(CloseEvent.CLOSE, closeHandler);
			
			function closeHandler(event:CloseEvent):void
			{	
				if (event.currentTarget.objName.text)
				{
					//todo проверить на существование
					newFilePath += "\\"+event.currentTarget.objName.text +".xml";
					newFile = newFile.resolvePath(newFilePath);
					trace(newFile.exists);
					original.copyTo(newFile, true);	
					facade.sendNotification( CreateObjectMediator.CREATE_GUIDS, newFile );						
				}
			}	
		}
	}
}