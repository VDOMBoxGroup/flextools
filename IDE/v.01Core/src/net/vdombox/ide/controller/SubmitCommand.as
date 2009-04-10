package net.vdombox.ide.controller
{
	import net.vdombox.ide.model.LoginProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SubmitCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var loginData : Object = notification.getBody();
			var loginProxy : LoginProxy = facade.retrieveProxy( LoginProxy.NAME ) as
				LoginProxy;
			loginProxy.login( loginData.username, loginData.password, loginData.hostname );
		}
	}
}