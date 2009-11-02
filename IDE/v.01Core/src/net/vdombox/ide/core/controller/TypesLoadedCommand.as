package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.view.ApplicationMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class TypesLoadedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var applicationMediator : ApplicationMediator = facade.retrieveMediator( ApplicationMediator.NAME ) as ApplicationMediator;

			applicationMediator.openMainWindow();
		}
	}
}