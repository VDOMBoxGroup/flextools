package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;

	import org.puremvc.as3.multicore.interfaces.INotification;
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