package net.vdombox.ide.modules.edition.controller
{
	import net.vdombox.ide.modules.edition.ApplicationFacade;
	import net.vdombox.ide.modules.edition.view.BodyMediator;
	import net.vdombox.ide.modules.edition.view.components.Body;
	
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