package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.BodyMediator;
	import net.vdombox.ide.modules.applicationsManagment.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class CreateBodyCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body = new Body();
			
			facade.registerMediator( new BodyMediator( body ) )
			
			facade.sendNotification( ApplicationFacade.EXPORT_BODY, body );
		}
	}
}