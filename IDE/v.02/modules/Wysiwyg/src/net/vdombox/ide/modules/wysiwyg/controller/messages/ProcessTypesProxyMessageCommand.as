package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * This command gives to <b>TypesProxy</b> geted  <b>TypesVO</b><br />
	 *  <ul><br />
	 * 
	 *  <b>Registred on:</b><ul>
	 *  ApplicationFacade.PROCESS_TYPES_PROXY_MESSAGE</ul><br />
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
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
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
					sendNotification( ApplicationFacade.TOP_LEVEL_TYPES_GETTED, body );
					
					break;
				}
			}
		}
	}
}