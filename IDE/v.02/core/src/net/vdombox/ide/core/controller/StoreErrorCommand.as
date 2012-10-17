package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.SessionProxy;
	import net.vdombox.ide.core.model.vo.ErrorVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StoreErrorCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			var name : String = notification.getName(); //not used
			var body : Object = notification.getBody();
			
			sessionProxy.errorVO = body as ErrorVO;
		}
	}
}