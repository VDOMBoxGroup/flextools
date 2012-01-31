package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.PPMStatesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.model.vo.ApplicationVO;
	import net.vdombox.ide.common.model.vo.ObjectVO;
	import net.vdombox.ide.common.model.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessStatesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var message : ProxyMessage = notification.getBody() as ProxyMessage;
			
			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;
			
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
					sessionProxy.selectedApplication = body as ApplicationVO;
					
					break;
				}
					
				case PPMStatesTargetNames.SELECTED_PAGE:
				{
					sessionProxy.selectedPage = body as PageVO;
					
					break;
				}
					
				case PPMStatesTargetNames.SELECTED_OBJECT:
				{
					sessionProxy.selectedObject = body as ObjectVO;
					
					break;
				}
			}
		}
	}
}