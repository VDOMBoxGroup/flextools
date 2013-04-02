package net.vdombox.ide.core.controller
{
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.view.components.button.ToolsetButton;
	import net.vdombox.ide.common.view.skins.button.ToolsetButtonSkin;
	import net.vdombox.ide.core.model.ApplicationsHostsProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	import net.vdombox.ide.core.view.components.PopUpApplicationsHosts;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import spark.components.Image;

	public class ShowApplicationsHostsCommand extends SimpleCommand
	{
		private var toolsetButton : ToolsetButton;
		private var popUpApplicationsHosts : PopUpApplicationsHosts;
		private var statesProxy : StatesProxy;
		private var applicationsHostsProxy : ApplicationsHostsProxy;
		private var host : String;
		private var toolsetButtonSkin : ToolsetButtonSkin;
		
		override public function execute( notification : INotification ) : void
		{
			toolsetButton = notification.getBody() as ToolsetButton;
			toolsetButtonSkin = toolsetButton.skin as ToolsetButtonSkin;
			toolsetButtonSkin.solidColor.visible = true;
			toolsetButtonSkin.labelDisplay.setStyle( 'color', 0xFFFFFF );
			
			var point : Point = toolsetButtonSkin.labelDisplay.localToGlobal( new Point( 0, toolsetButtonSkin.labelDisplay.height ) );
			
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			var applicationVO : ApplicationVO = statesProxy.selectedApplication;
			
			applicationsHostsProxy = facade.retrieveProxy( ApplicationsHostsProxy.NAME ) as ApplicationsHostsProxy;
			var selectedHost : String = applicationsHostsProxy.getSelectedHost( serverProxy.server + statesProxy.selectedApplication.id );
			
			popUpApplicationsHosts = new PopUpApplicationsHosts();
			popUpApplicationsHosts.setListData( applicationVO.hosts, selectedHost );
			popUpApplicationsHosts.show( toolsetButton, point.x - 5, point.y );
			popUpApplicationsHosts.setFocus();
			
			toolsetButton.parentApplication.stage.addEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler );
			popUpApplicationsHosts.addEventListener( FocusEvent.FOCUS_OUT, focusOutHandler );
			popUpApplicationsHosts.menu.addEventListener( PopUpWindowEvent.SELECT, menu_changeHandler, true );
		}
		
		private function stage_mouseDownHandler( event : MouseEvent ) : void
		{
			dispose();
		}
		
		private function focusOutHandler( event : FocusEvent ) : void
		{
			dispose();
		}
		
		private function menu_changeHandler( event : PopUpWindowEvent ) : void
		{
			host = event.target.data as String;
			
			
			applicationsHostsProxy.setSelectedHost( serverProxy.server + statesProxy.selectedApplication.id, host );
			
			if ( !canCreateURL )
				return
				
				navigateToURL( new URLRequest( URL ), '_blank' );
		}
		
		private function get serverProxy() : ServerProxy
		{
			return facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
		}
		
		private function get canCreateURL() : Boolean
		{
			return statesProxy.selectedApplication && statesProxy.selectedPage
		}
		
		private function get URL() : String
		{
			if( host == "default" )
				return "http://" + serverProxy.server + "/" + statesProxy.selectedApplication.id + "/" + statesProxy.selectedPage.id;
			else
				return "http://" + host + "/" + statesProxy.selectedPage.name;
		}
		
		private function dispose() : void
		{
			toolsetButtonSkin.solidColor.visible = false;
			toolsetButtonSkin.labelDisplay.setStyle( 'color', 0x9b9b9b );
			popUpApplicationsHosts.dispose();
			toolsetButton.parentApplication.stage.removeEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler );
			popUpApplicationsHosts.removeEventListener( FocusEvent.FOCUS_OUT, focusOutHandler );
		}
		
		
	}
}