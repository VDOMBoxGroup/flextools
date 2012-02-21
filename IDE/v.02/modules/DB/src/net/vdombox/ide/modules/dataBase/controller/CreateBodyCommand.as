package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.modules.DataBase;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.dataBase.view.BodyMediator;
	import net.vdombox.ide.modules.dataBase.view.DataBaseMediator;
	import net.vdombox.ide.modules.dataBase.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class CreateBodyCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body;
			var bodyMediator : BodyMediator;
			
			var resourceBrowserMediator : DataBaseMediator = facade.retrieveMediator( DataBaseMediator.NAME ) as DataBaseMediator;
			
			if( facade.hasMediator( BodyMediator.NAME ) )
			{
				bodyMediator = facade.retrieveMediator( BodyMediator.NAME ) as BodyMediator;
				body = bodyMediator.body;
			}
			else
			{
				body = new Body();
				facade.registerMediator( new BodyMediator( body ) )
			}
			
			body.moduleFactory = resourceBrowserMediator.resourceBrowser.moduleFactory;
			facade.sendNotification( Notifications.EXPORT_BODY, body );
		}
	}
}