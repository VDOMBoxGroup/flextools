package net.vdombox.ide.controller
{
	import net.vdombox.ide.view.ApplicationMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PreinitalizeCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var application : VdomIDE = notification.getBody() as VdomIDE;
			facade.registerMediator( new ApplicationMediator( application ) );
		}
	}
}