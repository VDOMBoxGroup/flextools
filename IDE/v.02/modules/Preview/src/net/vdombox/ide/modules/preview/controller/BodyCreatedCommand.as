package net.vdombox.ide.modules.events.controller
{
	import net.vdombox.ide.modules.events.view.EventsPanelMediator;
	import net.vdombox.ide.modules.events.view.ObjectsTreePanelMediator;
	import net.vdombox.ide.modules.events.view.WorkAreaMediator;
	import net.vdombox.ide.modules.events.view.components.Body;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class BodyCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body = notification.getBody() as Body;

			facade.registerMediator( new WorkAreaMediator( body.workArea ) );

			facade.registerMediator( new ObjectsTreePanelMediator( body.objectsTreePanel ) );
			facade.registerMediator( new EventsPanelMediator( body.eventsPanel ) );
		}
	}
}