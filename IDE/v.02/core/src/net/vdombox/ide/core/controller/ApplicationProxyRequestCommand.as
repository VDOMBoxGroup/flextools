package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMApplicationTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ApplicationProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			var applicationVO : ApplicationVO;

			if ( body is ApplicationVO )
				applicationVO = body as ApplicationVO;
			else if ( body.hasOwnProperty( "applicationVO" ))
				applicationVO = body.applicationVO as ApplicationVO;
			else
				throw new Error( "no application VO" );
			
			var applicationProxy : ApplicationProxy;
			applicationProxy = serverProxy.getApplicationProxy( applicationVO );
			
			switch ( target )
			{
				case PPMApplicationTargetNames.STRUCTURE:
				{
					applicationProxy.getStructure();
					
					break;
				}
					
				case PPMApplicationTargetNames.PAGES:
				{
					applicationProxy.getPages();

					break;
				}

				case PPMApplicationTargetNames.INFORMATION:
				{
					var applicationInformationVO : ApplicationInformationVO = body.applicationInformationVO;
					applicationProxy.changeApplicationInformation( applicationInformationVO );

					break;
				}
			}
		}
	}
}