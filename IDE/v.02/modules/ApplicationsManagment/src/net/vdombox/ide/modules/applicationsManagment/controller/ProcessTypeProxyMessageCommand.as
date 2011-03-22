package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * The ProcessTypeProxyMessageCommand is command to manipulate teked data   from a VDOM type content message. 
	 *  <ul>
	 *  <b>Registred on:</b><ul>
	 *  ApplicationFacade.PROCESS_TYPES_PROXY_MESSAGE</ul>
	 * </ul>
	 * 
	 * @see  net.vdombox.ide.modules.applicationsManagment.model.TypesProxy
	 * 
	 * @author Alexey Andreev
	 * 
	 */	
	public class ProcessTypeProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;
			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME) as TypesProxy;
			
			switch ( target )
			{
				case PPMTypesTargetNames.TYPES:
				{
					if ( operation == PPMOperationNames.READ  )
						if ( body is Array ) 
							typesProxy.types = body as Array;
					
					break;
				}
			}
		}
	}
}