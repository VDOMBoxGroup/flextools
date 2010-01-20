package net.vdombox.ide.modules.events.controller
{
	import net.vdombox.ide.modules.Events;
	import net.vdombox.ide.modules.events.model.SettingsProxy;
	import net.vdombox.ide.modules.events.view.EventsJunctionMediator;
	import net.vdombox.ide.modules.events.view.EventsMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : Events = note.getBody() as Events;

			facade.registerMediator( new EventsJunctionMediator() );
			facade.registerMediator( new EventsMediator( application ) )

			facade.registerProxy( new SettingsProxy() );
		}
	}
}