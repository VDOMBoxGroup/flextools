package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ApplicationLoadedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			
			typesProxy.loadTypes();
		}
	}
}