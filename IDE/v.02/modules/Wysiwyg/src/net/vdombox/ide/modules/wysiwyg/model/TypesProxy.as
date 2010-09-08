package net.vdombox.ide.modules.wysiwyg.model
{
	import net.vdombox.editors.parsers.vdomxml.Field;
	import net.vdombox.editors.parsers.vdomxml.TypeDB;
	import net.vdombox.ide.common.vo.AttributeDescriptionVO;
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

			TypeDB.removeDB( "vdom" );

			TypeDB.setDB( "vdom", typeDB );

			sendNotification( ApplicationFacade.TYPES_CHANGED, _types );
		}

		public function get typeDB() : TypeDB
		{
			var result : TypeDB = new TypeDB();
			result.dbName = "vdom";

			var typeVO : TypeVO;
			var typeField : Field;
			var attributeDescriptionVO : AttributeDescriptionVO;

			for each ( typeVO in _types )
			{
				typeField = new Field( "type", 0, typeVO.name );

				for each ( attributeDescriptionVO in typeVO.attributeDescriptions )
				{
					typeField.members.setValue( attributeDescriptionVO.name, new Field( "attribute", 0, attributeDescriptionVO.name ) );
				}

				result.addDefinition( typeField );
			}

			return result;
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
	}
}