package net.vdombox.ide.controller
{
	import net.vdombox.ide.model.ApplicationProxy;
	import net.vdombox.ide.model.ResourceProxy;
	import net.vdombox.ide.model.TypeProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ConnectCompleteCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			facade.registerProxy( new ResourceProxy() );
			
			var typeProxy : TypeProxy = new TypeProxy();
			facade.registerProxy( typeProxy );
			typeProxy.load();
		}
	}
}