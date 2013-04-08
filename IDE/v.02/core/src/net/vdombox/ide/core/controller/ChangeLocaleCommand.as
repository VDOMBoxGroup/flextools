package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.LocalesProxy;
	import net.vdombox.ide.core.model.vo.LocaleVO;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeLocaleCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var localesProxy : LocalesProxy = facade.retrieveProxy( LocalesProxy.NAME ) as LocalesProxy;

			var localeVO : LocaleVO = notification.getBody() as LocaleVO;

			if ( localeVO && ( !localesProxy.currentLocale || localeVO.code != localesProxy.currentLocale.code ) )
				localesProxy.changeLocale( localeVO );
		}
	}
}
