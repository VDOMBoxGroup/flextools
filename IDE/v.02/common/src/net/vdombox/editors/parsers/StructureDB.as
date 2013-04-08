package net.vdombox.editors.parsers
{
	import net.vdombox.editors.parsers.base.BackwardsParser;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.view.components.VDOMImage;

	public class StructureDB
	{
		static private var _structure : Object;

		static private var _pageXML : XML;

		static private var _objectXML : XML;

		public function StructureDB()
		{
		}

		static public function set structure( value : XML ) : void
		{
			if ( !_structure )
				_structure = [];

			_structure[ value.@id ] = value;
		}

		static public function getChildrenForObject( selfObjectVO : IVDOMObjectVO, bp : BackwardsParser ) : Vector.<AutoCompleteItemVO>
		{
			var a : Vector.<AutoCompleteItemVO> = new Vector.<AutoCompleteItemVO>();

			var pageVO : PageVO = selfObjectVO is PageVO ? selfObjectVO as PageVO : ObjectVO( selfObjectVO ).pageVO;

			_pageXML = _structure[ pageVO.id ];

			if ( !_pageXML )
				return a;

			var objects : XMLList;
			var object : XML;
			var flag : Boolean = false;
			var typeDB : TypeDB = TypeDB.inst;

			if ( selfObjectVO is PageVO )
			{
				objects = _pageXML.children();

				if ( bp.names.length > 1 )
				{
					for ( var i : int = 1; i < bp.names.length; i++ )
					{
						flag = false;

						for each ( object in objects )
						{
							if ( object.@name == bp.names[ i ] )
							{
								objects = object.children();
								flag = true;
								break;
							}
						}

						if ( !flag )
							return a;
					}
				}


				a = object ? typeDB.getVectorByType( object.@typeID ) : typeDB.getVectorByType( selfObjectVO.typeVO.id );

				for each ( object in objects )
				{
					a.push( new AutoCompleteItemVO( VDOMImage.Standard, object.@name ) );
				}
			}
			else
			{
				objects = _pageXML..object;

				for each ( object in objects )
				{
					if ( object.@id == selfObjectVO.id )
					{
						objects = object.children();
						flag = true;
						break;
					}
				}

				if ( !flag )
					return a;

				if ( bp.names.length > 1 )
				{
					for ( i = 1; i < bp.names.length; i++ )
					{
						flag = false;

						for each ( object in objects )
						{
							if ( object.@name == bp.names[ i ] )
							{
								objects = object.children();
								flag = true;
								break;
							}
						}

						if ( !flag )
							return a;
					}
				}


				a = object ? typeDB.getVectorByType( object.@typeID ) : typeDB.getVectorByType( selfObjectVO.typeVO.id );

				for each ( object in objects )
				{
					a.push( new AutoCompleteItemVO( VDOMImage.Standard, object.@name ) );
				}
			}

			return a;
		}
	}
}
