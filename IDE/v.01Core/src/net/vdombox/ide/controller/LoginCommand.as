package net.vdombox.ide.controller
{	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class LoginCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var dummy : * = ""; // FIXME remove dummy
		}
	}
}