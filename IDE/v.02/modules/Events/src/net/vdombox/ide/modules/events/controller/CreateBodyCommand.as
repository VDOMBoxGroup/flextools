package net.vdombox.ide.modules.events.controller
{
	import flash.events.Event;
	
	import mx.modules.Module;
	
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.view.BodyMediator;
	import net.vdombox.ide.modules.events.view.EventsMediator;
	import net.vdombox.ide.modules.events.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	
	/**
	 * The CreateBodyCommand creating body of Events
	 * @author Alexey Andreev
	 * 
	 */
	public class CreateBodyCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body;
			var bodyMediator : BodyMediator;

			var eventsMediator : EventsMediator = facade.retrieveMediator( EventsMediator.NAME ) as EventsMediator;
			
			if ( facade.hasMediator( BodyMediator.NAME ) )
			{
				bodyMediator = facade.retrieveMediator( BodyMediator.NAME ) as BodyMediator;
				body = bodyMediator.body;
			}
			else
			{
				body = new Body();
				facade.registerMediator( new BodyMediator( body ) );
			}
			
			body.moduleFactory = eventsMediator.events.moduleFactory;
			facade.sendNotification( ApplicationFacade.EXPORT_BODY, body );
			facade.sendNotification( ApplicationFacade.MODULE_SELECTED );
		}
	}
}