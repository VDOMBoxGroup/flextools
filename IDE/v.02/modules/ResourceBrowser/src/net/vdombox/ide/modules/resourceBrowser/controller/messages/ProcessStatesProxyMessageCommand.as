package net.vdombox.ide.modules.resourceBrowser.controller.messages
{
	import net.vdombox.ide.common.PPMStatesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.resourceBrowser.ApplicationFacade;
	import net.vdombox.ide.modules.resourceBrowser.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessStatesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var body : Object = message.getBody();
			var place : String = message.getPlace();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();
			
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