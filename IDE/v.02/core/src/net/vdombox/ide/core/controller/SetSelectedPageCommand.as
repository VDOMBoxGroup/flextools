package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.core.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	
	
	public class SetSelectedPageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			//var name : String = notification.getName();
			var body : Object = notification.getBody();

			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var indexPageID : String = statesProxy.selectedApplication.indexPageID;
			if ( statesProxy.selectedPage == null)
			{
				// IndexPageID not exist. Set first page as indexPageID.
				if ( !indexPageID || indexPageID == "None" )
				{
					statesProxy.selectedApplication.indexPageID = body.pages[0].id;
					indexPageID = body.pages[0].id;
				}
				
				for each ( var page:PageVO in body.pages)
				{
					if (page.id == indexPageID)
					{
						statesProxy.selectedPage = page;
						break;
					}
				}
			}
		}
	}
}