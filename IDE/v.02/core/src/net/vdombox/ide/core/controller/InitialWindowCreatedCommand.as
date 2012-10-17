package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.view.ErrorViewMediator;
	import net.vdombox.ide.core.view.LoginViewMediator;
	import net.vdombox.ide.core.view.ProgressViewMediator;
	import net.vdombox.ide.core.view.components.InitialWindow;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class InitialWindowCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var initialWindow : InitialWindow = notification.getBody() as InitialWindow;
			
			if ( !facade.hasMediator( ProgressViewMediator.NAME ) )
			{
				var progressViewMediator : ProgressViewMediator = new ProgressViewMediator( initialWindow.progressView )
				facade.registerMediator( progressViewMediator );
			}

			if ( !facade.hasMediator( LoginViewMediator.NAME ) )
			{
				var loginViewMediator : LoginViewMediator = new LoginViewMediator( initialWindow.loginView );
				facade.registerMediator( loginViewMediator );
			}

			if ( !facade.hasMediator( ErrorViewMediator.NAME ) )
			{
				var errorViewMediator : ErrorViewMediator = new ErrorViewMediator( initialWindow.errorView );
				facade.registerMediator( errorViewMediator );
			}
		}
	}
}