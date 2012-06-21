package net.vdombox.object_editor.controller
{
	import net.vdombox.object_editor.model.proxy.ServerProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ConnectInfoVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class UploadTypeToServerCommand extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void  
		{
			var objectTypeVO:ObjectTypeVO = note.getBody() as ObjectTypeVO;
			
			var objTypeProxy:ObjectTypeProxy = facade.retrieveProxy( ObjectTypeProxy.NAME ) as ObjectTypeProxy;
			
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			serverProxy.uploadType( objTypeProxy.toXMLString( objectTypeVO ) );
		}
	}
}