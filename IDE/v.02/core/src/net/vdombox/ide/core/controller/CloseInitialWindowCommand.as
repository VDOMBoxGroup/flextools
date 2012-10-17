package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.view.ErrorViewMediator;
	import net.vdombox.ide.core.view.InitialWindowMediator;
	import net.vdombox.ide.core.view.LoginViewMediator;
	import net.vdombox.ide.core.view.ProgressViewMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CloseInitialWindowCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			
			if ( facade.hasMediator( LoginViewMediator.NAME ) )
				facade.removeMediator( LoginViewMediator.NAME );
			
			if ( facade.hasMediator( ErrorViewMediator.NAME ) )
				facade.removeMediator( ErrorViewMediator.NAME );
			
			if ( facade.hasMediator( ProgressViewMediator.NAME ) )
				facade.removeMediator( ProgressViewMediator.NAME );
			
			if ( facade.hasMediator( InitialWindowMediator.NAME ) )
			{
				var initialWindowMediator : InitialWindowMediator = facade.retrieveMediator( InitialWindowMediator.NAME ) as InitialWindowMediator;
				facade.removeMediator( InitialWindowMediator.NAME );
				initialWindowMediator.closeWindow();
			}
			
		}
	}
}