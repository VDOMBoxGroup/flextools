package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.core.model.ResourcesProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SetResourceIconCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var resourceVO : ResourceVO;

			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;

			if ( body is ResourceVO )
				resourceVO = body as ResourceVO;
			else if ( body.hasOwnProperty( "resourceVO" ) )
				resourceVO = body.resourceVO;

			var nameMed : String;


			if ( resourceVO )
				resourcesProxy.setResource( resourceVO );

		}
	}
}
