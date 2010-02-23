package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.PPMStatesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessStatesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();
			
			switch ( target )
			{
				case PPMStatesTargetNames.SELECTED_APPLICATION:
				{
					var selectedApplicationVO : ApplicationVO = notification.getBody() as ApplicationVO;
					
					sessionProxy.selectedApplication = selectedApplicationVO
					sendNotification( ApplicationFacade.SELECTED_APPLICATION_GETTED, body );
					
					break;
				}
					
				case PPMStatesTargetNames.SELECTED_PAGE:
				{
					var selectedPageVO : PageVO = notification.getBody() as PageVO;
					
					sessionProxy.selectedPage = selectedPageVO
					sendNotification( ApplicationFacade.SELECTED_PAGE_GETTED, body );
					
					break;
				}
					
				case PPMStatesTargetNames.SELECTED_OBJECT:
				{
					var selectedObjectVO : ObjectVO = notification.getBody() as ObjectVO;
					
					sessionProxy.selectedObject = selectedObjectVO
					sendNotification( ApplicationFacade.SELECTED_OBJECT_GETTED, body );
					
					break;
				}
			}
		}
	}
}