package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.view.BodyMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class TreeElementsChangedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var bodyMediator : BodyMediator = facade.retrieveMediator( BodyMediator.NAME ) as BodyMediator;
			
			bodyMediator.createTreeElements( notification.getBody() as Array );
		}
	}
}