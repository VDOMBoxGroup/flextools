package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMResourcesTargetNames;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.ResourcesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessResourcesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var operation : String = message.operation;
			var target : String = message.target;

			var body : Object = message.getBody();

			switch ( target )
			{
				case PPMResourcesTargetNames.RESOURCE:
				{
					if ( operation == PPMOperationNames.CREATE )
						sendNotification( ApplicationFacade.RESOURCE_SETTED, body );
					
					break;
				}
					
				case PPMResourcesTargetNames.RESOURCES:
				{					
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.RESOURCES_GETTED, body );

					break;
				}
				
				case PPMResourcesTargetNames.ICON:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.ICON_GETTED, body );	
					
					break;
				}
			}
		}
	}
}