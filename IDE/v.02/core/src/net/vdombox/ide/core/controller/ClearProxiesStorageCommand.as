package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.model.ProxyStorage;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ClearProxiesStorageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var proxies : Array = ProxyStorage.proxies;
			
			for each ( var proxyName : String in proxies )
			{
				if ( facade.hasProxy( proxyName ) )
					facade.removeProxy( proxyName );
			}
			
			ProxyStorage.removeAllProxies();
		}
	}
}