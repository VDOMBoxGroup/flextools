package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.model._vo.ApplicationInformationVO;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.SessionProxy;
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
			
			if (!body || !body.pageVO)
			{
				statesProxy.selectedPage = null;
				return;
			}
			
			statesProxy.selectedPage = body.pageVO;
			
		}
		
	}
}