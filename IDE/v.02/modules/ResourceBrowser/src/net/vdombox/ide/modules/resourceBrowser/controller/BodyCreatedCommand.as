package net.vdombox.ide.modules.resourceBrowser.controller
{
	import net.vdombox.ide.modules.resourceBrowser.view.ResourcesAreaMediator;
	import net.vdombox.ide.modules.resourceBrowser.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class BodyCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body = notification.getBody() as Body;

			facade.registerMediator( new ResourcesAreaMediator( body.resourcesArea ) );

			/*facade.registerMediator( new WorkAreaMediator( body.workArea ) );

			facade.registerMediator( new ResourcesLoaderMediator( body.workArea.resourcesLoader ) );
			facade.registerMediator( new PreviewAreaMediator( body.workArea.previewArea ) );
			facade.registerMediator( new InfoAreaMediator( body.workArea.infoArea ) );*/
		}
	}
}