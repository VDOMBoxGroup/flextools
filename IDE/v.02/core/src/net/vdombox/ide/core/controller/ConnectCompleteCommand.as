package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ResourcesProxy;
	import net.vdombox.ide.core.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ConnectCompleteCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			facade.registerProxy( new ResourcesProxy() );
			
			var typeProxy : TypesProxy = new TypesProxy();
			facade.registerProxy( typeProxy );
			typeProxy.load();
		}
	}
}