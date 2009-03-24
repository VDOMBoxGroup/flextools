package net.vdombox.ide.controller
{
	
	import net.vdombox.ide.model.ApplicationProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class InvokeCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var attributes : Array = notification.getBody() as Array;
			var applicationProxy : ApplicationProxy = facade.retrieveProxy( "ApplicationProxy" ) as ApplicationProxy;
			applicationProxy.attributes = attributes;
		}
	}
}