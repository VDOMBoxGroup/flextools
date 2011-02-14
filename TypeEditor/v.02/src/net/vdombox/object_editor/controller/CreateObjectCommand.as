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
	
	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.model.proxy.FileProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class CreateObjectCommand extends SimpleCommand implements ICommand
	{   
		override public function execute(note:INotification):void   
		{
			var original:File = new File();			
			var orPath:String = "C:/flexProject/ObjectEditor2/src/assets/newObject";//?
			original = original.resolvePath(orPath + "/newObject.xml");			
			trace(original.exists);
			
			
			var newFile:File = File.documentsDirectory;
			var newFilePath:String = "";
			
			var so:SharedObject = SharedObject.getLocal("directoryPath");
			var path:String = so.data.path;
			if (path)
				newFilePath = path + "/newFile.txt";
			else
				newFilePath = File.documentsDirectory.nativePath + "/newFile.txt";
															//todo add popUp with TextInput for put fileName
															//диалоговое окно!!! куда и как назвать
															//проверить на существование
			newFile = newFile.resolvePath(newFilePath);
			trace(newFile.exists);
			original.copyTo(newFile, true);					
			
				
//			var item:Item = note.getBody() as Item;			
						
//			var xmlFile:XML = new XML(fileData);
//			var objTypeProxy:ObjectTypeProxy = facade.retrieveProxy(ObjectTypeProxy.NAME) as ObjectTypeProxy;
//			
//			objTypeProxy.newObjectTypeVO(xmlFile, item.path);
		}
	}
}