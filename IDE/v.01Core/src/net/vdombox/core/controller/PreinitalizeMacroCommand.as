package net.vdombox.ide.controller
{
	import net.vdombox.ide.model.ApplicationProxy;
	import net.vdombox.ide.view.ApplicationMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.MacroCommand;

	public class PreinitalizeMacroCommand extends MacroCommand
	{
		override protected function initializeMacroCommand() : void
		{
			addSubCommand( ModelPrepCommand );
			addSubCommand( ViewPrepCommand );
		}
	}
}