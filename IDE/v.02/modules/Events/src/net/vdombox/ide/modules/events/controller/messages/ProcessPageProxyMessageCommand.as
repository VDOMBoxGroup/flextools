package net.vdombox.ide.modules.events.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var place : String = message.getPlace();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			var pageVO : PageVO = body.pageVO as PageVO;
			
			switch ( target )
			{
				case PPMPageTargetNames.SERVER_ACTIONS:
				{
					sendNotification( ApplicationFacade.SERVER_ACTIONS_GETTED, body );
					
					break;
				}
					
				case PPMPageTargetNames.OBJECT:
				{
//					if ( operation == PPMOperationNames.CREATE )
//					{
//						sendNotification( ApplicationFacade.OBJECT_CREATED, body.objectVO );
//						sendNotification( ApplicationFacade.GET_PAGE_WYSIWYG, sessionProxy.selectedPage );
//					}
//					else 
					if ( operation == PPMOperationNames.READ )
					{
						sendNotification( ApplicationFacade.OBJECT_GETTED, body.objectVO );
					}
//					else if ( operation == PPMOperationNames.DELETE )
//					{
//						sendNotification( ApplicationFacade.OBJECT_DELETED, body.objectVO );
//						sendNotification( ApplicationFacade.GET_PAGE_WYSIWYG, sessionProxy.selectedPage );
//					}

					break;
				}

				case PPMPageTargetNames.STRUCTURE:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.PAGE_STRUCTURE_GETTED, body );

					break;
				}

				case PPMPageTargetNames.ATTRIBUTES:
				{
//					var pageAttributesVO : PageAttributesVO = body.pageAttributesVO as PageAttributesVO;
//
//					if ( operation == PPMOperationNames.READ )
//						sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_GETTED, pageAttributesVO );
//					else if ( operation == PPMOperationNames.UPDATE )
//						sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_GETTED, pageAttributesVO );
//
//					if( needForUpdateObject.hasOwnProperty( pageAttributesVO.pageVO.id ) )
//						sendNotification( ApplicationFacade.GET_PAGE_WYSIWYG, pageAttributesVO.pageVO );
						
					break;
				}
			}
		}
	}
}