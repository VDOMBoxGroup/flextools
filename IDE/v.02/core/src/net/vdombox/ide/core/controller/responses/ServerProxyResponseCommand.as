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
//
					message = new ProxyMessage( PPMPlaceNames.SERVER, PPMOperationNames.READ, PPMServerTargetNames.APPLICATIONS, applications );
//
//					break;
					var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
					
					var settingsStorageProxy : SettingsStorageProxy = facade.retrieveProxy( SettingsStorageProxy.NAME ) as SettingsStorageProxy;
					
					var settings : Object = settingsStorageProxy.loadSettings( "applicationManagerWindow" );
					
					if ( !statesProxy.selectedApplication )
					{
						var settingsProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
						
						settingsProxy.importSettings( settings );
						var settingsVO : SettingsVO = settingsProxy.settings;
						
						var newSelectedApplication : ApplicationVO;
						
						if ( !applications || applications.length == 0 )
							break;
						
						if ( settingsVO )
						{
							for ( var i : int = 0; i < applications.length; i++ )
							{
								if ( applications[ i ].id == settingsVO.lastApplicationID )
								{
									newSelectedApplication = applications[ i ];
									break;
								}
							}
						}
						
						if( !newSelectedApplication )
							newSelectedApplication = applications[ 0 ];
						
						sendNotification( ApplicationFacade.SET_SELECTED_APPLICATION, newSelectedApplication );
						//sendNotification( ApplicationFacade.OPEN_APPLICATION_IN_EDITOR, newSelectedApplication );
					}
				}
			}

			sendNotification( ApplicationFacade.SERVER_PROXY_RESPONSE, message );
		}
	}
}