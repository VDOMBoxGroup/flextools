package net.vdombox.ide.core.controller.responses
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.core.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class PageProxyResponseCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			var message : ProxiesPipeMessage;
			
			switch ( name )
			{
				case ApplicationFacade.PAGE_OBJECT_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECT, body );
					
					break;
				}
				
				case ApplicationFacade.PAGE_OBJECTS_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECTS, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_OBJECT_CREATED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.CREATE, PPMPageTargetNames.OBJECT, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_OBJECT_DELETED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.DELETE, PPMPageTargetNames.OBJECT, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_STRUCTURE_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.STRUCTURE, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_ATTRIBUTES_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.ATTRIBUTES, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_ATTRIBUTES_SETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.ATTRIBUTES, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_SERVER_ACTIONS_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.SERVER_ACTIONS, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_SERVER_ACTIONS_SETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.SERVER_ACTIONS, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_WYSIWYG_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.WYSIWYG, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_XML_PRESENTATION_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.XML_PRESENTATION, body );
					
					break;
				}
					
				case ApplicationFacade.PAGE_XML_PRESENTATION_SETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.XML_PRESENTATION, body );
					
					break;
				}
			}
			
			if ( message )
				sendNotification( ApplicationFacade.PAGE_PROXY_RESPONSE, message );
		}
	}
}