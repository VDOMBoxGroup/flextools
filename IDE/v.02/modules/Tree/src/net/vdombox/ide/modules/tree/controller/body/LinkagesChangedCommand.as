package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.view.BodyMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class LinkagesChangedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var bodyMediator : BodyMediator = facade.retrieveMediator( BodyMediator.NAME ) as BodyMediator;
			
			bodyMediator.createLinkages( notification.getBody() as Array );
		}
	}
}