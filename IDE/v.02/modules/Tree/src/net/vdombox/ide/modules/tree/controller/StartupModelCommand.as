package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.SettingsProxy;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupModelCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var sessionProxy : SessionProxy = new SessionProxy();
			
			facade.registerProxy( new SessionProxy() );
			facade.registerProxy( new SettingsProxy() );
			facade.registerProxy( new StructureProxy() );
			
			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );
			
			statesObject[ ApplicationFacade.SELECTED_APPLICATION ] = null;
			statesObject[ ApplicationFacade.SELECTED_PAGE ] = null;
		}
	}
}