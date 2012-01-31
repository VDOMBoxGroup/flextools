package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.model.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.model.vo.ApplicationVO;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	/**
	 * After getting pages selected index page 
	 * @author Alexey Andreev
	 * 
	 */	
	
	public class SetIndexPageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var pageId : String = body.pageID;
			
			var applicationVO : ApplicationVO; 
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var applicationInformationVO : ApplicationInformationVO = new ApplicationInformationVO();
			
			try
			{
				applicationVO = statesProxy.selectedApplication;
			}
			catch( error : Error )
			{}
			
			if( applicationVO )
			{
				applicationInformationVO.indexPageID = pageId;
				
				applicationInformationVO.name = applicationVO.name;
				applicationInformationVO.description = applicationVO.description;
				applicationInformationVO.iconID = applicationVO.iconID;
				applicationInformationVO.scriptingLanguage = applicationVO.scriptingLanguage;
				applicationInformationVO.active = applicationVO.active;
				
				
				var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
				var applicationProxy : ApplicationProxy;
				
				applicationProxy = serverProxy.getApplicationProxy( applicationVO );
				applicationProxy.changeApplicationInformation( applicationInformationVO );
			}
		}
	}
			
}
