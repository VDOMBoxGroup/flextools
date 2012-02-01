package net.vdombox.ide.modules.events.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPageTargetNames;
	import net.vdombox.ide.common.model.SessionProxy;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var place : String = message.proxy;
			var target : String = message.target;
			var operation : String = message.operation;

			var pageVO : PageVO = body.pageVO as PageVO;
			
			switch ( target )
			{
				case PPMPageTargetNames.SERVER_ACTIONS_LIST:
				{
					sendNotification( ApplicationFacade.SERVER_ACTIONS_LIST_GETTED, body.serverActions as Array );
					
					break;
				}
					
				case PPMPageTargetNames.SERVER_ACTIONS:
				{
					if( PPMOperationNames.READ )
						sendNotification( ApplicationFacade.SERVER_ACTIONS_GETTED, body );
					else if( PPMOperationNames.UPDATE )
						sendNotification( ApplicationFacade.SERVER_ACTIONS_SETTED, body.serverActions );
					
					break;
				}
					
				case PPMPageTargetNames.SERVER_ACTION:
				{
					sendNotification( ApplicationFacade.GET_SERVER_ACTIONS_REQUEST );
					sendNotification( ApplicationFacade.GET_APPLICATION_EVENTS,
						{ applicationVO: sessionProxy.selectedApplication, pageVO: sessionProxy.selectedPage } );
					
					break;
				}	
					
				case PPMPageTargetNames.XML_PRESENTATION:
				{
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