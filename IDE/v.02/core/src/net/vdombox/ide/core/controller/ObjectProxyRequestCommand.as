package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.core.model.ObjectProxy;
	import net.vdombox.ide.core.model.PageProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ObjectProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var pageProxy : PageProxy;
			var objectProxy : ObjectProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			var objectVO : ObjectVO;

			if ( body is ObjectVO )
				objectVO = body as ObjectVO;
			else if ( body.hasOwnProperty( "objectVO" ) )
				objectVO = body.objectVO as ObjectVO;
			else
				throw new Error( "no object VO" );

			pageProxy = facade.retrieveProxy( PageProxy.NAME + "/" + objectVO.applicationID + "/" + objectVO.pageID ) as PageProxy;
			objectProxy = pageProxy.getObjectProxy( objectVO );
			
			switch ( target )
			{
				case PPMObjectTargetNames.ATTRIBUTES:
				{
					objectProxy.getAttributes();
					
					break;
				}
					
				case PPMObjectTargetNames.SERVER_ACTIONS:
				{
					objectProxy.getServerActions();
					
					break;
				}
			}
		}
	}
}