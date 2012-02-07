package net.vdombox.ide.modules.events.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMApplicationTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessApplicationProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;

			var applicationVO : ApplicationVO;

			if ( body is ApplicationVO )
				applicationVO = body as ApplicationVO;
			else if ( body.hasOwnProperty( "applicationVO" ) )
				applicationVO = body.applicationVO as ApplicationVO;
			else
				throw new Error( "no application VO" );

			switch ( target )
			{
				case PPMApplicationTargetNames.SAVED:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.CHECK_SAVE_IN_WORKAREA , null );
					else if ( operation == PPMOperationNames.UPDATE )
					{
						sendNotification( ApplicationFacade.SAVE_CHANGED );
					}
						
					
					break;
				}
					
				case PPMApplicationTargetNames.PAGES:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.PAGES_GETTED, body.pages );
					
					break;
				}
					
				case PPMApplicationTargetNames.EVENTS:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.APPLICATION_EVENTS_GETTED, body.applicationEvents );
					else if ( operation == PPMOperationNames.UPDATE )
					{
						sendNotification( ApplicationFacade.APPLICATION_EVENTS_SETTED );
						if ( body.hasOwnProperty("needForUpdate") )
						{
							if ( body.needForUpdate )
								sendNotification( ApplicationFacade.GET_APPLICATION_EVENTS,
									{ applicationVO: statesProxy.selectedApplication, pageVO: statesProxy.selectedPage } );
						}
					}
					break;
				}
			}
		}
	}
}