package net.vdombox.ide.modules.wysiwyg.model
{
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class TypesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "TypesProxy";

		public function TypesProxy()
		{
			super( NAME );
		}
		
		private var _types : Array;
		
		public function get types() : Array
		{
			return _types;
		}
		
		public function set types( types : Array ) : void
		{
			_types = types;
			
			sendNotification( ApplicationFacade.TYPES_CHANGED, _types );
		}
		
		public function getTypeVObyID( typeID : String ) : TypeVO
		{
			var result : TypeVO;
			var typeVO : TypeVO;
			
			for each( typeVO in _types )
			{
				if( typeVO.id == typeID )
				{
					result = typeVO;
					break;
				}
			}
			
			return result;
		}
	}
}