package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.model.vo.ApplicationInformationVO;
	import net.vdombox.ide.core.model.ServerProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateApplicationCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var applicationInformationVO : ApplicationInformationVO = notification.getBody() as ApplicationInformationVO;
			if ( applicationInformationVO )
			{
				var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
				serverProxy.createApplication( applicationInformationVO );
			}
		}
	}
}