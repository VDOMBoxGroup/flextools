package net.vdombox.ide.modules.scripts.controller.messages
{
	import net.vdombox.ide.common.PPMStatesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessStatesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );

			switch ( target )
			{
				case PPMStatesTargetNames.SELECTED_APPLICATION:
				{
					var selectedApplication : ApplicationVO = body as ApplicationVO;
					statesObject[ ApplicationFacade.SELECTED_APPLICATION ] = selectedApplication;

					sendNotification( ApplicationFacade.SELECTED_APPLICATION_GETTED, body );

					break;
				}

				case PPMStatesTargetNames.SELECTED_PAGE:
				{
					var selectedPageVO : PageVO = body as PageVO;

					if ( statesObject[ ApplicationFacade.SELECTED_PAGE ] != selectedPageVO )
					{
						statesObject[ ApplicationFacade.SELECTED_PAGE ] = selectedPageVO;

						sendNotification( ApplicationFacade.SELECTED_PAGE_CHANGED, body );
					}

					break;
				}
			}
		}
	}
}