package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class BodyStopCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			var settingsProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			
			statesProxy.cleanup();
			typesProxy.cleanup();
			//settingsProxy.cleanup();
			renderProxy.cleanup();
		}
	}
}