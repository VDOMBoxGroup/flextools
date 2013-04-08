package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.modules.scripts.model.SaveParametersTabsProxy;
	import net.vdombox.ide.modules.scripts.view.components.Body;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SaveParametersTabsCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var librariesBoxWidth : int = body.librariesBox;
			var actionsBoxWidth : int = body.actionsBox;
			var containersPanelHeight : Number = body.containersPanel as Number;
			var globalScriptsPanelHeight : Number = body.globalScriptsPanel as Number;

			var saveParametersTabsProxy : SaveParametersTabsProxy = facade.retrieveProxy( SaveParametersTabsProxy.NAME ) as SaveParametersTabsProxy;

			saveParametersTabsProxy.libraryWidth = librariesBoxWidth;
			saveParametersTabsProxy.actionsWidth = actionsBoxWidth;
			saveParametersTabsProxy.containersHeight = containersPanelHeight;
			saveParametersTabsProxy.globalScriptsHeight = globalScriptsPanelHeight;
		}
	}
}
