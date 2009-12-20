package net.vdombox.ide.modules.resourceBrowser.controller
{
	import net.vdombox.ide.modules.ResourceBrowser;
	import net.vdombox.ide.modules.resourceBrowser.model.SettingsProxy;
	import net.vdombox.ide.modules.resourceBrowser.view.ResourceBrowserJunctionMediator;
	import net.vdombox.ide.modules.resourceBrowser.view.ResourceBrowserMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : ResourceBrowser = note.getBody() as ResourceBrowser;
			
			facade.registerMediator( new ResourceBrowserJunctionMediator() );
			facade.registerMediator( new ResourceBrowserMediator( application ) )
				
			facade.registerProxy( new SettingsProxy() );
		}
	}
}