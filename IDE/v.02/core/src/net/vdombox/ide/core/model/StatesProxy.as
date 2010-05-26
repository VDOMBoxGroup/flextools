package net.vdombox.ide.core.model
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class StatesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "StatesProxy";

		public static const SELECTED_APPLICATION : String = "selectedApplication";
		public static const SELECTED_PAGE : String = "selectedPage";
		public static const SELECTED_OBJECT : String = "selectedObject";
		
		public static const ERROR : String = "error";
		
		public function StatesProxy()
		{
			super( NAME, {} );
		}

		override public function onRemove() : void
		{
			cleanup();
		}
		
		public function get selectedApplication() : ApplicationVO
		{
			return data[ SELECTED_APPLICATION ];
		}

		public function set selectedApplication( value : ApplicationVO ) : void
		{
			data[ SELECTED_APPLICATION ] = value;
			data[ SELECTED_PAGE ] = null;
			data[ SELECTED_OBJECT ] = null;
		}

		public function get selectedPage() : PageVO
		{
			return data[ SELECTED_PAGE ];
		}

		public function set selectedPage( value : PageVO ) : void
		{
			data[ SELECTED_PAGE ] = value;
			data[ SELECTED_OBJECT ] = null;
		}

		public function get selectedObject() : ObjectVO
		{
			return data[ SELECTED_OBJECT ];
		}

		public function set selectedObject( value : ObjectVO ) : void
		{
			data[ SELECTED_OBJECT ] = value;
		}

		public function get error() : Object
		{
			return data[ ERROR ];
		}
		
		public function set error( value : Object ) : void
		{
			data[ ERROR ] = value;
		}
		
		public function cleanup() : void
		{
			data = {};
		}
	}
}