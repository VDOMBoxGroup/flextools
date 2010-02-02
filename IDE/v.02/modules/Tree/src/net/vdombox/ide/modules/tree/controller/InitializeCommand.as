package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	import net.vdombox.ide.modules.tree.view.BodyMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class InitializeCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var bodySessionObject : Object = sessionProxy.getObject( ApplicationFacade.BODY_SESSION_OBJECT );

			var messageName : String = notification.getName();
			var messageBody : Object = notification.getBody();

			switch ( messageName )
			{
				case ApplicationFacade.PAGES_GETTED:
				{
					bodySessionObject[ "inititializeProcess" ] |= 1;

					var pages : Array = messageBody as Array;

					bodySessionObject[ "pages" ] = pages;

					break;
				}

				case ApplicationFacade.APPLICATION_STRUCTURE_GETTED:
				{
					bodySessionObject[ "inititializeProcess" ] |= 2;

					var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;

					structureProxy.setSructure( messageBody as Array );

					break;
				}
			}

			if ( bodySessionObject[ "inititializeProcess" ] == 3 )
				sendNotification( ApplicationFacade.INITIALIZE_COMPLETE );
		}
	}
}