package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.scripts.view.BodyMediator;
	import net.vdombox.ide.modules.scripts.view.ScriptsMediator;
	import net.vdombox.ide.modules.scripts.view.components.Body;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateBodyCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body;
			var bodyMediator : BodyMediator;

			var scriptsMediator : ScriptsMediator = facade.retrieveMediator( ScriptsMediator.NAME ) as ScriptsMediator;

			if ( facade.hasMediator( BodyMediator.NAME ) )
			{
				bodyMediator = facade.retrieveMediator( BodyMediator.NAME ) as BodyMediator;
				body = bodyMediator.body;
			}
			else
			{
				body = new Body();
				facade.registerMediator( new BodyMediator( body ) )
			}

			body.moduleFactory = scriptsMediator.scripts.moduleFactory;
			facade.sendNotification( Notifications.EXPORT_BODY, body );
			facade.sendNotification( Notifications.MODULE_SELECTED );
		}
	}
}
