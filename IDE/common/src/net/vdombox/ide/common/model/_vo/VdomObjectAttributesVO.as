package net.vdombox.ide.common.model._vo
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;

	/**
	 * The VdomObjectAttributesVO is Visual Object of Object Attributes.
	 * VdomObjectAttributesVO is contained in VDOM Object.
	 */
	public class VdomObjectAttributesVO
	{
		public function VdomObjectAttributesVO( vdomObjectVO : IVDOMObjectVO )
		{
			_objectVO = vdomObjectVO;
		}

		private var _objectVO : IVDOMObjectVO;

		private var _attributes : Vector.<AttributeVO>;

		private var _attributesObject : Object;

		private var _pageLinks : Vector.<ObjectListVO>;

		private var _objectsList : Vector.<ObjectListVO>;

		public function get vdomObjectVO() : IVDOMObjectVO
		{
			return _objectVO;
		}

		public function get attributes() : Vector.<AttributeVO>
		{
			return _attributes;
		}

		public function set attributes( value : Vector.<AttributeVO> ) : void
		{
			_attributes = value;
			_attributesObject = {};

			for each ( var attributeVO : AttributeVO in _attributes )
			{
				_attributesObject[ attributeVO.name ] = attributeVO
			}
		}

		public function getAttributeVOByName( name : String ) : AttributeVO
		{
			return _attributesObject[ name ];
		}

		public function get pageLinks() : Vector.<ObjectListVO>
		{
			return _pageLinks;
		}

		public function get objectsList() : Vector.<ObjectListVO>
		{
			return _objectsList;
		}

		public function setXMLDescription( xmlDescription : XML ) : void
		{
			var attributesXML : XML = xmlDescription.Attributes[ 0 ];
			var pageLinksXML : XML = xmlDescription.Pagelink[ 0 ];
			var objectsListXML : XML = xmlDescription.Objectlist[ 0 ];

			if ( attributesXML && attributesXML.length() > 0 )
				processAttributes( attributesXML );

			if ( pageLinksXML && pageLinksXML.length() > 0 )
				processPageLink( pageLinksXML );

			if ( objectsListXML && objectsListXML.length() > 0 )
				processObjectList( objectsListXML );
		}


		/**
		 * @return array of changed Attributes
		 */
		public function getChangedAttributes() : Array
		{
			var result : Array = [];

			var attributeVO : AttributeVO;
			for each ( attributeVO in attributes )
			{
				if ( attributeVO.defaultValue !== attributeVO.value )
				{
					result.push( attributeVO );
				}
			}

			return result;
		}

		public function clone( getUndo : Boolean = false ) : VdomObjectAttributesVO
		{
			var result : Vector.<AttributeVO> = new Vector.<AttributeVO>( attributes.length );

			var attributeVO : AttributeVO;
			var attributeVONew : AttributeVO;
			var i : int = 0;
			for each ( attributeVO in attributes )
			{
				attributeVONew = attributeVO.clone();

				if ( getUndo )
					attributeVONew.replaceValue();

				result[i++] = attributeVONew;
			}

			var undoAttributesVO : VdomObjectAttributesVO = new VdomObjectAttributesVO( _objectVO );
			undoAttributesVO.attributes = result;

			return undoAttributesVO;
		}

		private function processAttributes( attributesXML : XML ) : void
		{
			var attributesXMLList : XMLList = attributesXML.*;
			
			_attributes = new Vector.<AttributeVO>( attributesXML.length() );
			_attributesObject = {};
			
			var i : int = 0;
			var attributeVO : AttributeVO;
			for each ( var attributeXML : XML in attributesXMLList )
			{
				attributeVO = new AttributeVO( attributeXML.@Name, attributeXML[ 0 ] );
				_attributes[ i++ ] = attributeVO;
				_attributesObject[ attributeVO.name ] = attributeVO
			}
		}

		private function processPageLink( pageLinksXML : XML ) : void
		{
			var pageLinksXMLList : XMLList = pageLinksXML.*;
			
			_pageLinks = new Vector.<ObjectListVO>( pageLinksXMLList.length() );
			
			var i : int = 0;
			var objectListVO : ObjectListVO;
			for each ( var pageLinkXML : XML in pageLinksXMLList )
			{
				objectListVO = new ObjectListVO();
				objectListVO.id = pageLinkXML.@ID;
				objectListVO.name = pageLinkXML.@Name;
				_pageLinks[ i++ ] = objectListVO;
			}
		}

		private function processObjectList( objectsListXML : XML ) : void
		{
			var objectsListXMLList : XMLList = objectsListXML.*;
			
			_objectsList = new Vector.<ObjectListVO>( objectsListXMLList.length() );
			
			var i : int = 0;
			var objectListVO : ObjectListVO;
			for each ( var objectListXML : XML in objectsListXMLList )
			{
				objectListVO = new ObjectListVO();
				objectListVO.id = objectListXML.@ID;
				objectListVO.name = objectListXML.@Name;
				_objectsList[ i++ ] = objectListVO;
			}
		}
	}
}
