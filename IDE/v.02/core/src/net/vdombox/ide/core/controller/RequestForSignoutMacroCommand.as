package net.vdombox.ide.core.controller
{
	import org.puremvc.as3.multicore.patterns.command.MacroCommand;

	public class RequestForSignoutMacroCommand extends MacroCommand
	{
		override protected function initializeMacroCommand() : void
		{
			addSubCommand( CleanupProxiesCommand );
			addSubCommand( OpenInitialWindowCommand );
		}
	}
}