package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.ComponentsFactory;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeEnumVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeIntVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentBase;

	public class ContainerVO extends ComponentBase
	{
		private var _layout : AttributeEnumVO;
		private var _verticalSpasing : AttributeIntVO;
		private var _horizontalSpasing : AttributeIntVO;
		private var _verticalAlign : AttributeEnumVO;
		private var _horizontalAlign : AttributeEnumVO;
		
		private var _items : ArrayCollection;
		
		public function ContainerVO( value : XML = null )
		{
			super( value );
			
			name = "Container";
			
			if ( value && value.@['layout'][0] )
				layout = new AttributeEnumVO( 'layout', value.@['layout'], new Array( "vertical", "horizontal", "grid" ) );
			else
				layout = new AttributeEnumVO( 'layout', "vertical", new Array( "vertical", "horizontal", "grid" ) );
			
			if ( value && value.@['verticalSpasing'][0] )
				verticalSpasing = new AttributeIntVO( 'verticalSpasing', value.@['verticalSpasing'] );
			else
				verticalSpasing = new AttributeIntVO( 'verticalSpasing', 0 );
			
			if ( value && value.@['horizontalSpasing'][0] )
				horizontalSpasing = new AttributeIntVO( 'horizontalSpasing', value.@['horizontalSpasing'] );
			else
				horizontalSpasing = new AttributeIntVO( 'horizontalSpasing', 0 );
			
			if ( value && value.@['verticalAlign'][0] )
				verticalAlign = new AttributeEnumVO( 'verticalAlign', value.@['verticalAlign'], new Array( "top", "middle", "bottom" ) );
			else
				verticalAlign = new AttributeEnumVO( 'verticalAlign', "top", new Array( "top", "middle", "bottom" ) );
			
			if ( value && value.@['horizontalAlign'][0] )
				horizontalAlign = new AttributeEnumVO( 'horizontalAlign', value.@['horizontalAlign'], new Array( "left", "center", "right" ) );
			else
				horizontalAlign = new AttributeEnumVO( 'horizontalAlign', "left", new Array( "left", "center", "right" ) );
			
			if ( value && value.hasOwnProperty( "Items" ) )
			{
				items = new ArrayCollection();
				
				var xmlList : XMLList = value.Items[0].children();
				
				for each ( var xmlItem : XML in xmlList )
				{
					items.addItem( ComponentsFactory.getComponentByXML( xmlItem ) );
				}
				
				if ( layout.value == 'grid' )
					addEmptyToList();
			}
			else
			{
				items = new ArrayCollection();
			}
		}
		
		private function addEmptyToList() : void
		{
			var rowCount : int = 0;
			var columnCount : int = 0;
			
			for each ( var itemVO : ItemVO in items )
			{
				if ( itemVO.row && itemVO.row.value > rowCount )
					rowCount = itemVO.row.value;
				
				if ( itemVO.column && itemVO.column.value > columnCount )
					columnCount = itemVO.column.value;
			}
			
			var count : int = rowCount * columnCount;
			var i : int = 1;
			
			for each ( itemVO in items )
			{
				if ( !itemVO.row || !itemVO.column )
				{
					i++;
					continue;
				}
				
				var index : int = getIndexElement( itemVO.row.value, itemVO.column.value );
				
				while ( i < index )
				{
					var item : ItemVO = new ItemVO();
					item.component = new EmptyVO();
					items.addItemAt( item, i - 1 );
					i++;
				}
				
				i++;
			}
			
			function getIndexElement( row : int, column : int ) : int
			{
				var index : int = ( row - 1 ) * columnCount + column;
				
				return index
			}
		}

		public function get layout():AttributeEnumVO
		{
			return _layout;
		}

		public function set layout(value:AttributeEnumVO):void
		{
			_layout = value;
		}

		public function get verticalSpasing():AttributeIntVO
		{
			return _verticalSpasing;
		}

		public function set verticalSpasing(value:AttributeIntVO):void
		{
			_verticalSpasing = value;
		}

		public function get horizontalSpasing():AttributeIntVO
		{
			return _horizontalSpasing;
		}

		public function set horizontalSpasing(value:AttributeIntVO):void
		{
			_horizontalSpasing = value;
		}

		public function get verticalAlign():AttributeEnumVO
		{
			return _verticalAlign;
		}

		public function set verticalAlign(value:AttributeEnumVO):void
		{
			_verticalAlign = value;
		}

		public function get horizontalAlign():AttributeEnumVO
		{
			return _horizontalAlign;
		}

		public function set horizontalAlign(value:AttributeEnumVO):void
		{
			_horizontalAlign = value;
		}

		[Bindable]
		public function get items():ArrayCollection
		{
			return _items;
		}

		public function set items(value:ArrayCollection):void
		{
			_items = value;
		}

		public override function get attributes() : ArrayCollection
		{
			
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( layout );
			_attributes.addItem( verticalSpasing );
			_attributes.addItem( horizontalSpasing );
			_attributes.addItem( verticalAlign );
			_attributes.addItem( horizontalAlign );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <Container></Container>;
			
			xml.@layout = layout.value;
			xml.@verticalSpacing = verticalSpasing.value;
			xml.@horizontalSpasing = horizontalSpasing.value;
			xml.@verticalAlign = verticalAlign.value;
			xml.@horizontalAlign = horizontalAlign.value;
			
			var xml2 : XML = <Items></Items>;
			
			var componentBase : ItemVO;
			
			if ( layout.value != 'grid' )
			{
				for each ( componentBase in items )
				{
					xml2.appendChild( componentBase.toXML() );
				}
			}
			else
			{
				for each ( componentBase in items )
				{
					if ( !( componentBase.component is EmptyVO ) )
						xml2.appendChild( componentBase.toXMLByGrig() );
				}
			}
			
			xml.appendChild( xml2 );

			return xml;
		}
	}
}