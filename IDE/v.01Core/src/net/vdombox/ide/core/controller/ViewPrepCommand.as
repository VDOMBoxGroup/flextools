package net.vdombox.ide.core.controller
{	
	import net.vdombox.ide.core.view.ApplicationMediator;
	import net.vdombox.ide.core.view.CoreJunctionMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ViewPrepCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var application : VdomIDE = notification.getBody() as VdomIDE;
			facade.registerMediator( new CoreJunctionMediator() );
			facade.registerMediator( new ApplicationMediator( application ) );
		}
	}
}