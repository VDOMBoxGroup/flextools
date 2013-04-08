package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.StatesProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * After getting pages selected index page
	 * @author Alexey Andreev
	 *
	 */

	public class SetSelectedPageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			if ( !body || !body.pageVO )
			{
				statesProxy.selectedPage = null;
				return;
			}

			statesProxy.selectedPage = body.pageVO;

		}

	}
}