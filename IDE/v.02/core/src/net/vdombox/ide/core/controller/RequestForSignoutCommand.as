package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.ObjectProxy;
	import net.vdombox.ide.core.model.PageProxy;
	import net.vdombox.ide.core.model.PipesProxy;
	import net.vdombox.ide.core.model.ResourcesProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	import net.vdombox.ide.core.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RequestForSignoutCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var pipesProxy : PipesProxy = facade.retrieveProxy( PipesProxy.NAME ) as PipesProxy;
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			var instanceName : String;
			
			serverProxy.disconnect();
			
			pipesProxy.cleanup();
			typesProxy.unloadTypes();
			statesProxy.cleanup();
			resourcesProxy.cleanup();
			
			for ( instanceName in ApplicationProxy.instances )
			{
				facade.removeProxy( instanceName );
			}
			
			for ( instanceName in PageProxy.instances )
			{
				facade.removeProxy( instanceName );
			}
			
			for ( instanceName in ObjectProxy.instances )
			{
				facade.removeProxy( instanceName );
			}
			
			sendNotification( ApplicationFacade.OPEN_INITIAL_WINDOW );
		}
	}
}