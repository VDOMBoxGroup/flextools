package net.vdombox.object_editor.controller
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import net.vdombox.object_editor.model.proxy.FileProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.mediators.ObjectViewMediator;
	
	import org.osmf.utils.OSMFStrings;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class SaveObjectTypeCommand extends SimpleCommand 
	{
		override public function execute( note:INotification  ) :void
		{
			var objTypeVO:ObjectTypeVO = note.getBody() as ObjectTypeVO;
			
			objTypeVO.languages.sortOnID();

			var objTypeProxy:ObjectTypeProxy = facade.retrieveProxy( ObjectTypeProxy.NAME ) as ObjectTypeProxy;
			var fileProxy:FileProxy = facade.retrieveProxy( FileProxy.NAME ) as FileProxy;

			fileProxy.saveFile( objTypeProxy.toXMLString( objTypeVO ), objTypeVO.filePath );
			facade.sendNotification(ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED, objTypeVO);
		}
	}
}

