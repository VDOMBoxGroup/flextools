package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.PageVO;
	
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
			
			var pageVO : PageVO;
			
			if ( body is PageVO )
				pageVO = body as PageVO;
			else if ( body.hasOwnProperty( "pageVO" ))
				pageVO = body.pageVO as PageVO;
			else
				throw new Error( "no pageVO" );
			
			switch ( target )
			{
				case PPMPageTargetNames.ATTRIBUTES :
				{
					
					break;
				}
			}
		}
	}
}