package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();
			
			switch ( target )
			{
				case PPMPageTargetNames.ATTRIBUTES :
				{

					var pageAttributesVO : PageAttributesVO = body as PageAttributesVO;
					
					if( pageAttributesVO )
					{
						sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_GETTED, pageAttributesVO.attributes );
					}
					
					break;
				}
			}
		}
	}
}