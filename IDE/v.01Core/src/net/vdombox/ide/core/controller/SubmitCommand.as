package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.vo.AuthInfo;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SubmitCommand extends SimpleCommand
	{

		override public function execute( notification : INotification ) : void
		{
			var submitFormData : Object = notification.getBody();
			var authInfo : AuthInfo = new AuthInfo( submitFormData.username, submitFormData.password, submitFormData.hostname )
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			serverProxy.connect( authInfo );
		}
	}
}