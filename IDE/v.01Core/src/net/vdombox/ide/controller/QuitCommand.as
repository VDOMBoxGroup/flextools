package net.vdombox.ide.controller
{
	import mx.core.FlexGlobals;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class QuitCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			FlexGlobals.topLevelApplication.exit();
		}
	}
}