/*
   Class OpenObjectCommand opens the file and sends a message to display it
 */
package net.vdombox.object_editor.controller
{
	import flash.filesystem.File;

	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.model.proxy.FileProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;

	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class OpenObjectCommand extends SimpleCommand
	{   
		override public function execute(note:INotification):void    
		{
			var item:Item = note.getBody() as Item;			

			var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
			var xmlFile:XML = fileProxy.getXML(item.path);
			var objTypeProxy:ObjectTypeProxy = facade.retrieveProxy(ObjectTypeProxy.NAME) as ObjectTypeProxy;

			
			objTypeProxy.newObjectTypeVO(xmlFile, item.path);
		}
	}
}

