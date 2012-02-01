package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	import net.vdombox.ide.modules.tree.view.BodyMediator;
	import net.vdombox.ide.modules.tree.view.TreeMediator;
	import net.vdombox.ide.modules.tree.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	/**
	 * The CreateBodyCommand creating body of Tree
	 * @author Alexey Andreev
	 * 
	 */
	public class CreateBodyCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			
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
			
			facade.sendNotification( ApplicationFacade.EXPORT_BODY, body );
			facade.sendNotification( ApplicationFacade.MODULE_SELECTED );
		}
	}
}