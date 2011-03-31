package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
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
			facade.sendNotification( ApplicationFacade.EXPORT_BODY, body );
			facade.sendNotification( ApplicationFacade.MODULE_SELECTED );
		}
	}
}