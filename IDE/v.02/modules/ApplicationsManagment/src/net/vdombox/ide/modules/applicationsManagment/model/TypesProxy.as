package net.vdombox.ide.modules.applicationsManagment.model
{
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	/**
	 * TypeProxy for manipulate whith object of <b>TapeVO</b> class<br />
	 * 
	 * @author Alexey Andreev
	 * 
	 * @flowerModelElementId _DE2aoEomEeC-JfVEe_-0Aw
	 */
	public class TypesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "typesProxy";
		
		public function TypesProxy( data : Object = null )
		{
			super( NAME, data );
		}
		
		/**
		 * Array of TypeVO 
		 */		
		private var _types : Array;
		
		public function get types() : Array
		{
			if( !_types )
				_types = [];
			
			return _types;
		}
		
		public function set types( types : Array ) : void
		{
			_types = types;
			
//			sendNotification( ApplicationFacade.TYPES_CHANGED, _types );
		}
		public function getTypeVObyID( typeID : String ) : TypeVO
		{
			var result : TypeVO;
			var typeVO : TypeVO;
			
			for each ( typeVO in _types )
			{
				if ( typeVO.id == typeID )
				{
					result = typeVO;
					break;
				}
			}
			
			return result;
		}
		
		public function cleanup() : void
		{
			_types = null;
		}
	}
}