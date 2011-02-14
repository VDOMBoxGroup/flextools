/*
   Class CreateObjectCommand create new object used newObject.mxml as the basis. 
   Generate new ID for Object and new ID for Icons.
 */
package net.vdombox.object_editor.controller
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.utils.object_proxy;
	
	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.model.proxy.FileProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.popups.NameObject;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class CreateObjectCommand extends SimpleCommand implements ICommand
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
				newFilePath = path; //+ "/newFile.xml";
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
				}
			}	
		
			//create Item: путь известен
			//сгенерировать ID объекта
			//сгенерировать ID для иконок
//			var item:Item = note.getBody() as Item;			
						
//			var xmlFile:XML = new XML(fileData);
//			var objTypeProxy:ObjectTypeProxy = facade.retrieveProxy(ObjectTypeProxy.NAME) as ObjectTypeProxy;
//			
//			objTypeProxy.newObjectTypeVO(xmlFile, item.path);
		}
	}
}