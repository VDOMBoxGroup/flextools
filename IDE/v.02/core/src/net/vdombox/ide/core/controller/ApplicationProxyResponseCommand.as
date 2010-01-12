package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMApplicationTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ApplicationProxyResponseCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			var message : ProxiesPipeMessage;

			switch ( name )
			{
				case ApplicationFacade.APPLICATION_CHANGED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.UPDATE, PPMApplicationTargetNames.INFORMATION, body );

					break;
				}

				case ApplicationFacade.PAGES_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.PAGES, body );

					break;
				}
			}

			if ( message )
				sendNotification( ApplicationFacade.APPLICATION_PROXY_RESPONSE, message );
		}
	}
}