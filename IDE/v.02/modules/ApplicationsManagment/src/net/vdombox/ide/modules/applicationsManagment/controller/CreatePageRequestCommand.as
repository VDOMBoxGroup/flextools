package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.model.SessionProxy;
	import net.vdombox.ide.modules.applicationsManagment.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * CreatePageRequestCommand takes <b>ApplicationVO</b> and <b>TypeVO</b> to request creating a page of application.<br /><br />
	 * <ul>
	 * 
	 *  * <b>Registred on:</b><ul>
	 *  ApplicationFacade.CREATE_PAGE_REQUEST</ul><br />
	 * 
	 * <b>Notifies:</b><ul>
	 *  ApplicationFacade.CREATE_PAGE</ul><br />
	 * </ul>
	 * 
	 *  @author Alexey Andreev
	 *  
	 */
	public class CreatePageRequestCommand extends SimpleCommand
	{
		/**
		 * 
		 * @param notification
		 * 
		 */			
		override public function execute( notification : INotification ) : void
		{
//			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var typesProxy : TypesProxy =  facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			var typeVO : TypeVO = typesProxy.getTypeVObyID("2330fe83-8cd6-4ed5-907d-11874e7ebcf4");
			var applicationVO : ApplicationVO = notification.getBody() as ApplicationVO;

			sendNotification( ApplicationFacade.CREATE_PAGE,
				{ applicationVO: applicationVO, typeVO: typeVO } );
		}
	}
}