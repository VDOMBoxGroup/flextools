package net.vdombox.ide.core.controller.responses
{
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.core.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	/**
	 * @flowerModelElementId _DB7CcEomEeC-JfVEe_-0Aw
	 */
	public class ObjectProxyResponseCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			var message : ProxyMessage;
			
			switch ( name )
			{
				case ApplicationFacade.OBJECT_ATTRIBUTES_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.ATTRIBUTES, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_ATTRIBUTES_SETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.UPDATE, PPMObjectTargetNames.ATTRIBUTES, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_NAME_SETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.UPDATE, PPMObjectTargetNames.NAME, body );
					
					break;
				}	
					
				case ApplicationFacade.OBJECT_SERVER_ACTIONS_LIST_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.SERVER_ACTIONS_LIST, body );
					
					break;
				}
				
				case ApplicationFacade.OBJECT_SERVER_ACTION_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.SERVER_ACTION, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_SERVER_ACTIONS_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.SERVER_ACTIONS, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_SERVER_ACTION_SETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.UPDATE, PPMObjectTargetNames.SERVER_ACTION, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_SERVER_ACTION_CREATED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.CREATE, PPMObjectTargetNames.SERVER_ACTION, body );
					
					break;
				}
					
				/*case ApplicationFacade.OBJECT_SERVER_ACTION_RENAMED:
				{
				message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.SERVER_ACTION, body );
				
				break;
				}*/
					
				case ApplicationFacade.OBJECT_SERVER_ACTION_DELETED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.DELETE, PPMObjectTargetNames.SERVER_ACTION, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_OBJECT_CREATED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.CREATE, PPMObjectTargetNames.OBJECT, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_WYSIWYG_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.WYSIWYG, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_XML_PRESENTATION_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.XML_PRESENTATION, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_XML_PRESENTATION_SETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.UPDATE, PPMObjectTargetNames.XML_PRESENTATION, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_COPY_CREATED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.CREATE, PPMObjectTargetNames.COPY, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_REMOTE_CALL_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.REMOTE_CALL, body );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_REMOTE_CALL_ERROR_GETTED:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.REMOTE_CALL, body );
					
					break;
				}
			}
			
			if ( message )
				sendNotification( ApplicationFacade.OBJECT_PROXY_RESPONSE, message );
		}
	}
}