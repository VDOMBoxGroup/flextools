package net.vdombox.ide.controller
{
	import net.vdombox.ide.model.ResourcesProxy;
	import net.vdombox.ide.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ConnectCompleteCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var typesProxy : TypesProxy = new TypesProxy();
			facade.registerProxy( typesProxy );
			facade.registerProxy( new ResourcesProxy() );
			
			typesProxy.load();
		}
	}
}