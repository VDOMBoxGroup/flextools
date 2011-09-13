package net.vdombox.ide.modules.preview.controller.settings
{
	import net.vdombox.ide.modules.preview.model.SettingsProxy;
	import net.vdombox.ide.modules.preview.model.vo.SettingsVO;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SaveSettingsToProxy extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;

			var settingsVO : SettingsVO = notification.getBody() as SettingsVO;

			settingsProxy.setSettings( settingsVO );
		}
	}
}