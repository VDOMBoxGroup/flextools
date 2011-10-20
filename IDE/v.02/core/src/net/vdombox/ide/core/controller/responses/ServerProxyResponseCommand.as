package net.vdombox.ide.core.controller.responses
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PPMServerTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.SettingsProxy;
	import net.vdombox.ide.core.model.SettingsStorageProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	import net.vdombox.ide.core.model.vo.SettingsVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * @flowerModelElementId _DCBJEEomEeC-JfVEe_-0Aw
	 */
	public class ServerProxyResponseCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			var message : ProxyMessage;

			switch ( notification.getName() )
			{
				case ApplicationFacade.SERVER_APPLICATION_CREATED:
				{
					var applicationVO : ApplicationVO = body as ApplicationVO;

					if ( !applicationVO )
					{
						sendNotification( ApplicationFacade.SEND_TO_LOG, "ServerProxyResponseCommand: APPLICATION_CREATED applicationVO is null." );
						return;
					}

					message = new ProxyMessage( PPMPlaceNames.SERVER, PPMOperationNames.CREATE, PPMServerTargetNames.APPLICATION, applicationVO );

					break;
				}

				case ApplicationFacade.SERVER_APPLICATIONS_GETTED:
				{
					var applications : Array = body as Array;
					var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
//
					message = new ProxyMessage( PPMPlaceNames.SERVER, PPMOperationNames.READ, PPMServerTargetNames.APPLICATIONS, applications );
					
					if ( !statesProxy.selectedApplication )
						sendNotification( ApplicationFacade.SET_SELECTED_APPLICATION );
					break;
				
				}
			}

			sendNotification( ApplicationFacade.SERVER_PROXY_RESPONSE, message );
		}
	}
}