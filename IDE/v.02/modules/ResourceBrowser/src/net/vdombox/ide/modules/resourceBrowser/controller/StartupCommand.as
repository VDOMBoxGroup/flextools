package net.vdombox.ide.modules.resourceBrowser.controller
{
	import net.vdombox.ide.modules.ResourceBrowser;
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.modules.resourceBrowser.view.ResourceBrowserJunctionMediator;
	import net.vdombox.ide.modules.resourceBrowser.view.ResourceBrowserMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.MacroCommand;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupCommand extends MacroCommand
	{
		override protected function initializeMacroCommand() : void
		{
			addSubCommand( StartupModelCommand );
			addSubCommand( StartupViewCommand );
		}
	}
}