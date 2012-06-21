package net.vdombox.object_editor.controller
{
	import net.vdombox.object_editor.model.proxy.ServerProxy;
	import net.vdombox.object_editor.model.vo.ConnectInfoVO;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class ConnectToServerCommand extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void  
		{
			var connectInfoVO:ConnectInfoVO = note.getBody() as ConnectInfoVO;
			
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			serverProxy.connect( connectInfoVO );
		}
	}
}