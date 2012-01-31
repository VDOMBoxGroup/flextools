package net.vdombox.ide.modules.preview.controller.messages
{
	import net.vdombox.ide.common.controller.names.PPMStatesTargetNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.preview.ApplicationFacade;
	import net.vdombox.ide.modules.preview.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessStatesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;

			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			switch ( target )
			{
				case PPMStatesTargetNames.ALL_STATES:
				{
					sessionProxy.setStates( body );
					sendNotification( ApplicationFacade.ALL_STATES_GETTED, body );
					
					break;
				}
				
				case PPMStatesTargetNames.SELECTED_APPLICATION:
				{
					var selectedApplication : ApplicationVO = body as ApplicationVO;
					sessionProxy.selectedApplication = selectedApplication;

					break;
				}

				case PPMStatesTargetNames.SELECTED_PAGE:
				{
					var selectedPageVO : PageVO = body as PageVO;
					sessionProxy.selectedPage = selectedPageVO;
					
					break;
				}
					
				case PPMStatesTargetNames.SELECTED_OBJECT:
				{
					var selectedObjectVO : ObjectVO = body as ObjectVO;
					sessionProxy.selectedObject = selectedObjectVO;
					
					break;
				}
			}
		}
	}
}