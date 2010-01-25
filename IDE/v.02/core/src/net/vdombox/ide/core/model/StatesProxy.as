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
		
		public function StatesProxy()
		{
			super( NAME );
		}
		
		private var _selectedApplication : ApplicationVO;
		private var _selectedPage : PageVO;
		private var _selectedObject : ObjectVO;
		
		public function get selectedApplication() : ApplicationVO
		{
			return _selectedApplication;
		}
		
		public function set selectedApplication( value : ApplicationVO ) : void
		{
			_selectedApplication = value;
		}
		
		public function get selectedPage() : PageVO
		{
			return _selectedPage;
		}
		
		public function set selectedPage( value : PageVO ) : void
		{
			_selectedPage = value;
		}
		
		public function get selectedObject() : ObjectVO
		{
			return _selectedObject;
		}
		
		public function set selectedObject( value : ObjectVO ) : void
		{
			_selectedObject = value;
		}
	}
}