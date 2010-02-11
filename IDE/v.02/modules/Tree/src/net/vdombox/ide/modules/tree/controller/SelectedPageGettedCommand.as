package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class SelectedPageGettedCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			var pageVO : PageVO = notification.getBody() as PageVO;
			
			var sessionObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );
			
			var currentSelectedTreeElement : TreeElementVO = sessionObject[ ApplicationFacade.SELECTED_TREE_ELEMENT ];
			var selectedTreeElement : TreeElementVO;
			
			if( pageVO )
			{
				selectedTreeElement = structureProxy.getTreeElementByVO( pageVO );
			}
			else
			{
				if( !currentSelectedTreeElement )
				{
					if( structureProxy.treeElements.length > 0 )
						selectedTreeElement = structureProxy.treeElements[ 0 ];
				}
				else
				{
					sendNotification( ApplicationFacade.SET_SELECTED_PAGE, currentSelectedTreeElement.pageVO );
				}
			}
			
			if( selectedTreeElement && currentSelectedTreeElement != selectedTreeElement )
				sendNotification( ApplicationFacade.SELECTED_TREE_ELEMENT_CHANGED, selectedTreeElement );
		}
	}
}