package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.PPMApplicationTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessApplicationProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			var applicationVO : ApplicationVO;

			if ( body is ApplicationVO )
				applicationVO = body as ApplicationVO;
			else if ( body.hasOwnProperty( "applicationVO" ) )
				applicationVO = body.applicationVO as ApplicationVO;
			else
				throw new Error( "no application VO" );

			switch ( message.getTarget() )
			{
				case PPMApplicationTargetNames.STRUCTURE:
				{
					sendNotification( ApplicationFacade.APPLICATION_STRUCTURE_GETTED, body.structure );
					break;
				}
				case PPMApplicationTargetNames.PAGE:
				{
					break;
				}
			}
		}
	}
}