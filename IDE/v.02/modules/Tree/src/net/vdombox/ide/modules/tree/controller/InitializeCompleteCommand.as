package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	import net.vdombox.ide.modules.tree.view.BodyMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class InitializeCompleteCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;
			var bodyMediator : BodyMediator = facade.retrieveMediator( BodyMediator.NAME ) as BodyMediator;
			
			var bodySessionObject : Object = sessionProxy.getObject( ApplicationFacade.BODY_SESSION_OBJECT );
			
			bodyMediator.createTreeElements( bodySessionObject[ "pages" ], structureProxy.structureElements );
			
			bodyMediator.createArrows( structureProxy.linkages );
		}
	}
}