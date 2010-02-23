package net.vdombox.ide.modules.wysiwyg.model
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SessionProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SessionProxy";

		public static const SELECTED_APPLICATION : String = "selectedApplication";
		public static const SELECTED_PAGE : String = "selectedPage";
		public static const SELECTED_OBJECT : String = "selectedObject";

		public function SessionProxy()
		{
			super( NAME, {} );
		}

		override public function onRemove() : void
		{
			data = null;
		}

		public function get selectedApplication() : ApplicationVO
		{
			return data[ SELECTED_APPLICATION ];
		}

		public function set selectedApplication( value : ApplicationVO ) : void
		{
			if ( data[ SELECTED_APPLICATION ] != value )
			{
				data[ SELECTED_APPLICATION ] = value;
				sendNotification( ApplicationFacade.SELECTED_APPLICATION_CHANGED, value );
			}
		}

		public function get selectedPage() : PageVO
		{
			return data[ SELECTED_PAGE ];
		}

		public function set selectedPage( value : PageVO ) : void
		{
			if ( data[ SELECTED_PAGE ] != value )
			{
				data[ SELECTED_PAGE ] = value;
				sendNotification( ApplicationFacade.SELECTED_PAGE_CHANGED, value );
			}
		}

		public function get selectedObject() : ObjectVO
		{
			return data[ SELECTED_OBJECT ];
		}

		public function set selectedObject( value : ObjectVO ) : void
		{
			if ( data[ SELECTED_OBJECT ] != value )
			{
				data[ SELECTED_OBJECT ] = value;
				sendNotification( ApplicationFacade.SELECTED_OBJECT_CHANGED, value );
			}
		}

		public function getObject( objectID : String ) : Object
		{
			if ( !data.hasOwnProperty( objectID ) )
				data[ objectID ] = {};

			return data[ objectID ];
		}
	}
}