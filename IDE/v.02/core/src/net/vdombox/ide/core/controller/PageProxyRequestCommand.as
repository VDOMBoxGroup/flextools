package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.PageProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PageProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var applicationProxy : ApplicationProxy;
			var pageProxy : PageProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			var pageVO : PageVO = body as PageVO;
			
			applicationProxy = facade.retrieveProxy( ApplicationProxy.NAME + "/" + pageVO.applicationID ) as ApplicationProxy;
			pageProxy = applicationProxy.getPageProxy( pageVO ) as PageProxy;
			
			switch ( target )
			{
				case PPMPageTargetNames.OBJECTS:
				{
					pageProxy.getObjects();
					
					break;
				}
					
				case PPMPageTargetNames.STRUCTURE:
				{	
					pageProxy.getStructure();
					
					break;
				}	
			}
		}
	}
}