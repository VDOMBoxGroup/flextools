package net.vdombox.ide.modules.preview.controller
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.modules.preview.ApplicationFacade;
	import net.vdombox.ide.modules.preview.view.CreateActionWindowMediator;
	import net.vdombox.ide.modules.preview.view.components.CreateActionWindow;
	
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
				title = resourceManager.getString( "Preview_General", "create_action_window_action_title" );
			else if ( target == ApplicationFacade.LIBRARY )
				title = resourceManager.getString( "Preview_General", "create_action_window_library_title" );
			else
				return;

			var createActionWindow : CreateActionWindow;
			var createActionWindowMediator : CreateActionWindowMediator;
			
			if( !facade.hasMediator( CreateActionWindowMediator.NAME ) )
			{
				createActionWindow = new CreateActionWindow();
				createActionWindowMediator = new CreateActionWindowMediator( createActionWindow );
				facade.registerMediator( createActionWindowMediator );
			}
			else
			{
				createActionWindowMediator = facade.retrieveMediator( CreateActionWindowMediator.NAME ) as CreateActionWindowMediator;
				createActionWindow = createActionWindowMediator.createActionWindow;
			}

			createActionWindowMediator.creationTarget = target;

			sendNotification( ApplicationFacade.OPEN_WINDOW, { content: createActionWindow, title: title, isModal: true, resizable: false } );
		}
	}
}