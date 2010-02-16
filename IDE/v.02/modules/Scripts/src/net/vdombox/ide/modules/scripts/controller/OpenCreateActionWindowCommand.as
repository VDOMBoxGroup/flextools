package net.vdombox.ide.modules.scripts.controller
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.view.CreateActionWindowMediator;
	import net.vdombox.ide.modules.scripts.view.components.CreateActionWindow;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class OpenCreateActionWindowCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var resourceManager : IResourceManager = ResourceManager.getInstance();

			var target : String = notification.getBody() as String;
			var title : String;

			if ( facade.hasMediator( CreateActionWindowMediator.NAME ) )
				facade.retrieveMediator( CreateActionWindowMediator.NAME );

			if ( target == ApplicationFacade.ACTION )
				title = resourceManager.getString( "Scripts_General", "create_action_window_action_title" );
			else if ( target == ApplicationFacade.LIBRARY )
				title = resourceManager.getString( "Scripts_General", "create_action_window_library_title" );
			else
				return;

			var createActionWindow : CreateActionWindow = new CreateActionWindow();
			var createActionWindowMediator : CreateActionWindowMediator = new CreateActionWindowMediator( createActionWindow );

			facade.registerMediator( createActionWindowMediator );

			createActionWindowMediator.creationTarget = target;

			sendNotification( ApplicationFacade.OPEN_WINDOW, { content: createActionWindow, title: title, isModal: true, resizable: false } );
		}
	}
}