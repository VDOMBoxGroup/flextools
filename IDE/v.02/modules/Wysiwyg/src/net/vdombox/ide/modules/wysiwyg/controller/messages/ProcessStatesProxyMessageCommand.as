package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMStatesTargetNames;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessStatesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var message : ProxyMessage = notification.getBody() as ProxyMessage;
			
			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;
			
			switch ( target )
			{
				case PPMStatesTargetNames.ALL_STATES:
				{
					statesProxy.setStates( body );
					
					sendNotification( StatesProxy.ALL_STATES_GETTED, body );
					
					break;
				}
				
				case PPMStatesTargetNames.SELECTED_APPLICATION:
				{
					statesProxy.selectedApplication = body as ApplicationVO;
					
					break;
				}
					
				case PPMStatesTargetNames.SELECTED_PAGE:
				{
					statesProxy.selectedPage = body as PageVO;
					
					break;
				}
					
				case PPMStatesTargetNames.SELECTED_OBJECT:
				{
					statesProxy.selectedObject = body as ObjectVO;
					
					break;
				}
			}
		}
	}
}