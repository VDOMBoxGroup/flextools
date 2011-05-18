package net.vdombox.object_editor.controller
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import mx.managers.PopUpManager;
	
	import net.vdombox.object_editor.view.mediators.CreateObjectMediator;
	import net.vdombox.object_editor.view.popups.NameObject;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * Command copy file "assets/newObject/newObject.xml" to users file with new name in the current directory.
	 * Finally Command send Notification: CreateObjectMediator.CREATE_GUIDS with new file.
	 * 
	 * @author Elena Kotlova
	 * 
	 */
	public class CreateXMLFileCommand extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void  
		{
			//open example file in applicationDirectory
			var original:File = File.applicationDirectory;			
			original = original.resolvePath("assets/newObject/newObject.xml");			
			trace("original.exists "+original.exists);
			
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
			popup.addEventListener(Event.ADDED_TO_STAGE, closeHandler);
			
			function closeHandler(event:Event):void
			{	
				if (event.currentTarget.objName.text)
				{
//todo проверить на существование
					newFilePath += "\\"+event.currentTarget.objName.text +".xml";
					newFile = newFile.resolvePath(newFilePath);
					trace("newFile.exists "+newFile.exists);
					original.copyTo(newFile, true);	
					facade.sendNotification( CreateObjectMediator.CREATE_GUIDS, newFile );						
				}
			}	
		}
	}
}