package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class EditApplicationInformationCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var applicationVO : ApplicationVO = body.applicationVO as ApplicationVO;
			
			var applicationInformationVO : ApplicationInformationVO = body.applicationInformationVO as ApplicationInformationVO;
			
			if( applicationVO )
			{
				
				var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
				
				var applicationProxy : ApplicationProxy = serverProxy.getApplicationProxy( applicationVO );
				applicationProxy.changeApplicationInformation( applicationInformationVO );
			}
		}
	}
}