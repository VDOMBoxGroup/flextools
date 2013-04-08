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

			_attributes = [];
			_pageLinks = [];
			_objectsList = [];
		}

		private var _objectVO : IVDOMObjectVO;

		private var _attributes : Array;

		private var _attributesObject : Object;

		private var _pageLinks : Array;

		private var _objectsList : Array;

		public function get vdomObjectVO() : IVDOMObjectVO
		{
			return _objectVO;
		}

		public function get attributes() : Array
		{
			return _attributes;
		}

		public function set attributes( value : Array ) : void
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

		public function get pageLinks() : Array
		{
			return _pageLinks;
		}

		public function get objectsList() : Array
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
			var result : Array = [];

			var attributeVO : AttributeVO;
			var attributeVONew : AttributeVO;
			for each ( attributeVO in attributes )
			{
				attributeVONew = attributeVO.clone();

				if ( getUndo )
					attributeVONew.replaceValue();

				result.push( attributeVONew );
			}

			var undoAttributesVO : VdomObjectAttributesVO = new VdomObjectAttributesVO( _objectVO );
			undoAttributesVO.attributes = result;

			return undoAttributesVO;
		}

		private function processAttributes( attributesXML : XML ) : void
		{
			var attributeVO : AttributeVO;
			_attributesObject = {};
			for each ( var attributeXML : XML in attributesXML.* )
			{
				attributeVO = new AttributeVO( attributeXML.@Name, attributeXML[ 0 ] );
				_attributes.push( attributeVO );
				_attributesObject[ attributeVO.name ] = attributeVO
			}
		}

		private function processPageLink( pageLinksXML : XML ) : void
		{
			var objectListVO : ObjectListVO;

			for each ( var pageLinkXML : XML in pageLinksXML.* )
			{
				objectListVO = new ObjectListVO();
				objectListVO.id = pageLinkXML.@ID;
				objectListVO.name = pageLinkXML.@Name;
				_pageLinks.push( objectListVO );
			}
		}

		private function processObjectList( objectsListXML : XML ) : void
		{
			var objectListVO : ObjectListVO;

			for each ( var objectListXML : XML in objectsListXML.* )
			{
				objectListVO = new ObjectListVO();
				objectListVO.id = objectListXML.@ID;
				objectListVO.name = objectListXML.@Name;
				_objectsList.push( objectListVO );
			}
		}
	}
}
