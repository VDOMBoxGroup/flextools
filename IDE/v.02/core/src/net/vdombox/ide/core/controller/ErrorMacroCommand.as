package net.vdombox.ide.core.controller
{
	import org.puremvc.as3.multicore.patterns.command.MacroCommand;

	public class ErrorMacroCommand extends MacroCommand
	{
		override protected function initializeMacroCommand() : void
		{
			addSubCommand( StoreErrorCommand );
			addSubCommand( CleanupProxiesCommand );
			addSubCommand( OpenInitialWindowCommand );
		}
	}
}
