package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.modules.DataBase;
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.modules.dataBase.view.DataBaseJunctionMediator;
	import net.vdombox.ide.modules.dataBase.view.DataBaseMediator;
	
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