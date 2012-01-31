package net.vdombox.ide.core.controller.requests
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMServerTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.model.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.model.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ServerProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * @flowerModelElementId _DBx4gEomEeC-JfVEe_-0Aw
	 */
	public class ServerProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var target : String = message.target;
			var operation : String = message.operation;

			switch ( target )
			{
				case PPMServerTargetNames.APPLICATION:
				{
					if ( operation == PPMOperationNames.CREATE )
						serverProxy.createApplication( message.getBody() as ApplicationInformationVO );
					
					break;
				}

				case PPMServerTargetNames.APPLICATIONS:
				{
					if ( operation == PPMOperationNames.READ )
						serverProxy.loadApplications();
					
					break;
				}
			}
		}
	}
}