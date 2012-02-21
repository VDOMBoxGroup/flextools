package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMTypesTargetNames;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.TypeVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * This command gives to <b>TypesProxy</b> geted  <b>TypesVO</b><br />
	 *  <ul><br />
	 * 
	 *  <b>Registred on:</b><ul>
	 *  Notifications.PROCESS_TYPES_PROXY_MESSAGE</ul><br />
	 * 
	 * <b>Notifies:</b><ul>Is Missing </ul><br />
	 * </ul> 
	 * 
	 * @author Alexey Andreev
	 * 
	 */
	public class ProcessTypesProxyMessageCommand extends SimpleCommand
	{	
		override public function execute( notification : INotification ) : void
		{
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var operation : String = message.operation;
			var target : String = message.target;

			var body : Object = message.getBody();

			switch ( target )
			{
				case PPMTypesTargetNames.TYPES:
				{
					if( operation == PPMOperationNames.READ )
						typesProxy.types = body as Array;
					
					break;
				}
					
				case PPMTypesTargetNames.TOP_LEVEL_TYPES:
				{
					sendNotification( Notifications.TOP_LEVEL_TYPES_GETTED, body );
					
					break;
				}
			}
		}
	}
}