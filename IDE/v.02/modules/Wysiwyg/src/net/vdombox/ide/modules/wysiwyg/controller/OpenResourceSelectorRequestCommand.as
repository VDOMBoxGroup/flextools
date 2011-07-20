package net.vdombox.ide.modules.wysiwyg.controller
{
	import flash.display.DisplayObject;
	
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.modules.wysiwyg.view.ResourceSelectorWindowMediator;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ResourceSelector;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ResourceSelectorWindow;
	import net.vdombox.ide.modules.wysiwyg.view.skins.MultilineWindowSkin;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class OpenResourceSelectorRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var resourceSelectorWindow : ResourceSelectorWindow = new ResourceSelectorWindow();
			var resourceSelector : ResourceSelector = notification.getBody() as ResourceSelector;
			var resourceSelectorMultiline : MultilineWindowSkin = notification.getBody() as MultilineWindowSkin;

			var resourceSelectorWindowMediator : ResourceSelectorWindowMediator = new ResourceSelectorWindowMediator( resourceSelectorWindow );
			resourceSelectorWindowMediator.resourceSelector = resourceSelector;
			resourceSelectorWindowMediator.resourceSelectorMultiline = resourceSelectorMultiline;
			
			facade.registerMediator( resourceSelectorWindowMediator );

			if (resourceSelector != null)
				PopUpManager.addPopUp( resourceSelectorWindow, DisplayObject( resourceSelector.parentApplication ), true );
			else
				PopUpManager.addPopUp( resourceSelectorWindow, DisplayObject( resourceSelectorMultiline.parentApplication ), true );
			PopUpManager.centerPopUp( resourceSelectorWindow );
		}
	}
}