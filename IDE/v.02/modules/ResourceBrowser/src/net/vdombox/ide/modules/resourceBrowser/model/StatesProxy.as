package net.vdombox.ide.modules.resourceBrowser.model
{
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ResourceVO;

	public class StatesProxy extends net.vdombox.ide.common.model.StatesProxy
	{
		public static const NAME : String = "StatesProxy";

		public static const SELECTED_APPLICATION : String = "selectedApplication";
		public static const SELECTED_PAGE : String = "selectedPage";
		public static const SELECTED_OBJECT : String = "selectedObject";
		public static const SELECTED_RESOURCE : String = "selectedResource";
		
		public static const CHANGE_SELECTED_RESOURCE_REQUEST : String = "changeSelectedResourceRequest";
		public static const SELECTED_RESOURCE_CHANGED : String = "selectedResourceChanged";
		
		//pipe
		public static const PROCESS_STATES_PROXY_MESSAGE 		: String = "processStatesProxyMessage";
		
		//states
		public static const GET_ALL_STATES 	  : String = "getAllStates";
		public static const ALL_STATES_GETTED : String = "allStatesGetted";
		
		public static const SET_ALL_STATES 	  : String = "setAllStates";
		public static const ALL_STATES_SETTED : String = "allStatesSetted";

		public function StatesProxy()
		{
			super();
		}

		override public function onRegister() : void
		{
			isSelectedApplicationChanged = false;
			isSelectedPageChanged = false;
			isSelectedObjectChanged = false;
		}

		override public function onRemove() : void
		{
			data = null;
		}
		
		public function get selectedResource() : ResourceVO
		{
			return data[ SELECTED_RESOURCE ];
		}
		
		public function set selectedResource( value : ResourceVO ) : void
		{
			if ( data[ SELECTED_RESOURCE ] == value )
				return;
			
			if ( data[ SELECTED_RESOURCE ] && value && data[ SELECTED_RESOURCE ].id == value.id )
				return;
			
			data[ SELECTED_RESOURCE ] = value;
			
			sendNotification( SELECTED_RESOURCE_CHANGED, data[ SELECTED_RESOURCE ] );
		}
	}
}