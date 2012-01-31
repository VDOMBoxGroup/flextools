package net.vdombox.ide.core.controller.responses
{
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPageTargetNames;
	import net.vdombox.ide.common.controller.names.PPMPlaceNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.core.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	/**
	 * @flowerModelElementId _DB9esEomEeC-JfVEe_-0Aw
	 */
	public class PageProxyResponseCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			var message : ProxyMessage;
			
			switch ( name )
			{
				case ApplicationFacade.PAGE_OBJECT_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECT, body );
					
					break;
				}
				
				case ApplicationFacade.PAGE_OBJECTS_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECTS, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_OBJECT_CREATED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.CREATE, PPMPageTargetNames.OBJECT, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_OBJECT_DELETED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.DELETE, PPMPageTargetNames.OBJECT, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_STRUCTURE_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.STRUCTURE, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_ATTRIBUTES_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.ATTRIBUTES, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_ATTRIBUTES_SETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.ATTRIBUTES, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_NAME_SETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.NAME, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_SERVER_ACTIONS_LIST_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.SERVER_ACTIONS_LIST, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_SERVER_ACTIONS_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.SERVER_ACTIONS, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_SERVER_ACTION_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.SERVER_ACTION, body );
					
					break;
				}
				
				case ApplicationFacade.PAGE_SERVER_ACTION_SETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.SERVER_ACTION, body );
					
					break;
				}
				
				case ApplicationFacade.PAGE_SERVER_ACTION_CREATED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.CREATE, PPMPageTargetNames.SERVER_ACTION, body );
					
					break;
				}
				
				/*case ApplicationFacade.PAGE_SERVER_ACTION_RENAMED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.SERVER_ACTION, body );
					
					break;
				}*/
					
				case ApplicationFacade.PAGE_SERVER_ACTION_DELETED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.DELETE, PPMPageTargetNames.SERVER_ACTION, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_WYSIWYG_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.WYSIWYG, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_XML_PRESENTATION_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.XML_PRESENTATION, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_REMOTE_CALL_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.REMOTE_CALL, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_REMOTE_CALL_ERROR_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.REMOTE_CALL, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_XML_PRESENTATION_SETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.XML_PRESENTATION, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_COPY_CREATED:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.CREATE, PPMPageTargetNames.COPY, body );
					
					break;
				}
			}
			
			if ( message )
				sendNotification( ApplicationFacade.PAGE_PROXY_RESPONSE, message );
		}
	}
}