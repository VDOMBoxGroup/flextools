//Макрокоманда, вызывает инициализаторы Model и View

package net.vdombox.ide.modules.sample.controller
{
	import org.puremvc.as3.multicore.patterns.command.MacroCommand;
	
	public class StartupCommand extends MacroCommand
	{
		override protected function initializeMacroCommand() : void
		{
			addSubCommand( StartupModelCommand );
			addSubCommand( StartupViewCommand );
		}
	}		
}