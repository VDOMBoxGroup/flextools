package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.StructureProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class InitializeCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;

			var bodySessionObject : Object = sessionProxy.getObject( ApplicationFacade.BODY_SESSION_OBJECT );

			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.PAGES_GETTED:
				{
					bodySessionObject[ "inititializeProcess" ] |= 1;

					structureProxy.setPages( body as Array );

					break;
				}

				case ApplicationFacade.APPLICATION_STRUCTURE_GETTED:
				{
					bodySessionObject[ "inititializeProcess" ] |= 2;

					structureProxy.setRawSructure( body as Array );

					break;
				}
			}

			sendNotification( ApplicationFacade.SEND_TO_LOG, "inititializeProcess = " + bodySessionObject[ "inititializeProcess" ] );

			if ( bodySessionObject[ "inititializeProcess" ] == 3 )
				sendNotification( ApplicationFacade.INITIALIZE_COMPLETE );
		}
	}
}