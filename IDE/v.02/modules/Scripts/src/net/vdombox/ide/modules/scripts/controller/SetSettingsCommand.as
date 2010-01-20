package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.vo.SettingsVO;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SetSettingsCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsVO : SettingsVO = notification.getBody() as SettingsVO;
			var settings : Object = settingsVO.toObject();

			sendNotification( ApplicationFacade.SAVE_SETTINGS_TO_PROXY, settingsVO );
			sendNotification( ApplicationFacade.SAVE_SETTINGS_TO_STORAGE, settings );
		}
	}
}