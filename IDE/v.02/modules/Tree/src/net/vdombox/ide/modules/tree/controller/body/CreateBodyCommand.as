package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.view.BodyMediator;
	import net.vdombox.ide.modules.tree.view.TreeMediator;
	import net.vdombox.ide.modules.tree.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateBodyCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			var body : Body;
			var bodyMediator : BodyMediator;

			var treeMediator : TreeMediator = facade.retrieveMediator( TreeMediator.NAME ) as TreeMediator;
			
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
			
			
			body.moduleFactory = treeMediator.tree.moduleFactory;
//			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );
//						
//			statesObject[ ApplicationFacade.SELECTED_APPLICATION ] = null;
//			statesObject[ ApplicationFacade.SELECTED_TREE_ELEMENT ] = null;
//			statesObject[ ApplicationFacade.SELECTED_TREE_LEVEL ] = null;
			
			facade.sendNotification( ApplicationFacade.EXPORT_BODY, body );
		}
	}
}