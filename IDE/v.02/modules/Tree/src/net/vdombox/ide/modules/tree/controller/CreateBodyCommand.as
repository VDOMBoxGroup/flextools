package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.view.BodyMediator;
	import net.vdombox.ide.modules.tree.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateBodyCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			
			var body : Body;
			var bodyMediator : BodyMediator;

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

			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			var bodySessionObject : Object = sessionProxy.getObject( ApplicationFacade.BODY_SESSION_OBJECT );
			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );
			
			bodySessionObject[ "inititializeProcess" ] = 0;
			bodySessionObject[ "pages" ] = [];
			statesObject[ ApplicationFacade.SELECTED_PAGE ] = null;
			
			facade.sendNotification( ApplicationFacade.EXPORT_BODY, body );
		}
	}
}